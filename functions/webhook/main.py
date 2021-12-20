#!/usr/bin/env python3
# -*- coding: utf-8 -*-
from time import sleep

import flask

from helper_functions import (
    create_logger,
    parse_req_object,
    query_bq,
    populate_uc3_template,
)

from config_bq import UC1_PT_QUERY_STRING, UC3_MRI_QUERY_STRING
from config_templates import (
    DEMO_RUNNER_ZIP_CODE,
    WARMP_UP_INTENTS,
    UC3_DISTANCE,
)


def handle_webhook_req(req: flask.wrappers.Request) -> dict:
    """
    Parse incoming DialogFlow request.

    :param req: Dialogflow request object

    :returns: Dialogflow dict response object
    """
    logger = create_logger("hcls-logger")

    req_json = req.get_json()
    intent = req_json["queryResult"]["intent"]["displayName"]
    logger.info(intent)

    # Commented out follow-up event examples
    """
    if intent == "db-testing-2":
        # logger.info(f"intent = db-testing-2\n{req_json}")
        parsed_zip = req_json["queryResult"]["parameters"]["zip-code"]
        # logger.info(f"Running db-testing-2, querying BQ, then sleeping for three seconds, zip code = {parsed_zip}")
        query_bq(logger, ZIP_BUFFER_QUERY_STRING, parsed_zip, False)
        sleep(4)
        return {
            "followupEventInput": {
                "name": "follow-up-event-provider-lookup",
                "parameters": {
                    "parsed_zip": parsed_zip,
                },
                "languageCode": "en-US",
            }
        }

    elif intent == "db-testing-2-followup":
        # logger.info(f"intent = db-testing-2-followup\n{req_json}")
        parsed_zip = req_json["queryResult"]["outputContexts"][1]["parameters"][
            "parsed_zip"
        ]
        sleep(4)
        return {
            "followupEventInput": {
                "name": "follow-up-event-provider-lookup-final",
                "parameters": {
                    "parsed_zip": parsed_zip,
                },
                "languageCode": "en-US",
            }
        }

    elif intent == "db-testing-3-followup":
        # logger.info(f"intent = db-testing-3-followup\n{req_json}")
        parsed_zip = req_json["queryResult"]["outputContexts"][0]["parameters"][
            "parsed_zip"
        ]
        providers = query_bq(logger, ZIP_BUFFER_QUERY_STRING, parsed_zip, True)
        return {"fulfillmentMessages": [{"text": {"text": [providers]}}]}
    """
    if intent in WARMP_UP_INTENTS:
        return WARMP_UP_INTENTS.get(intent).get("template")

    elif intent == "2.45-Find-Doctor":
        # Warms up query results
        # parsed_req = parse_req_object(logger, intent, req_json)
        query_bq(logger, UC1_PT_QUERY_STRING, DEMO_RUNNER_ZIP_CODE, False)
        sleep(3)

        return UC3_DISTANCE

    elif intent == "2.5-Find-Doctor":
        logger.info(req_json)
        # Somtimes this recieves multiple requests for some reason
        parsed_req = parse_req_object(logger, intent, req_json)

        providers = query_bq(logger, UC1_PT_QUERY_STRING, DEMO_RUNNER_ZIP_CODE, True)
        logger.info(providers)
        return "something"
        """
        return populate_uc3_template(
            logger, providers, parsed_req.get("parsed_distance")
        )
        """

    elif intent == "3.6-Compare":
        # Warms up query results
        parsed_req = parse_req_object(logger, intent, req_json)

        query_bq(logger, UC3_MRI_QUERY_STRING, parsed_req.get("parsed_zip"), False)
        sleep(3)

        return UC3_DISTANCE

    elif intent == "3.7-Compare":
        # Somtimes this recieves multiple requests for some reason
        parsed_req = parse_req_object(logger, intent, req_json)

        providers = query_bq(
            logger, UC3_MRI_QUERY_STRING, parsed_req.get("parsed_zip"), True
        )
        return populate_uc3_template(
            logger, providers, parsed_req.get("parsed_distance")
        )

    else:
        return {
            "fulfillmentMessages": [
                {
                    "text": {
                        "text": [
                            f"There are no fulfillment responses available or defined for Intent {intent}"
                        ]
                    }
                }
            ]
        }
