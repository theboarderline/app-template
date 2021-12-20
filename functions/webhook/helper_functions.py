#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import logging
import random
import sys

from google.cloud import bigquery

from config_bq import BQ_PROJECT
from config_templates import (
    UC3_SEE_MORE,
    UC3_ADDITIONAL_HELP,
    UC3_NEXT_STEPS_CHIPS,
    UC3_FALLBACK_TEMPLATE,
)


def create_logger(logger_name: str) -> logging.Logger:
    """
    Create logger object w/ console stream handler.

    :param logger_name: Logger name

    :returns: Logger object
    """
    logger = logging.getLogger(logger_name)
    logger.setLevel(logging.DEBUG)
    logger.addHandler(logging.StreamHandler(sys.stdout))

    return logger


def parse_req_object(
    logger: logging.Logger, intent: str, req_json: dict
) -> dict[str, str]:
    """
    Parse a Dialogflow req object.

    :param logger: Logger
    :param intent: Inbound Dialogflow intent name
    :param req_json: JSON request object

    :returns: Dict w/ parsed vars
    """
    try:
        parsed_req = {}
        if intent == "2.5-Find-Doctor":
            parsed_req["parsed_distance"] = req_json["queryResult"]["parameters"][
                "unit-length"
            ]["amount"]

        elif intent == "3.6-Compare":
            parsed_req["parsed_zip"] = req_json["queryResult"]["queryText"][:3]

        elif intent == "3.7-Compare":
            output_contexts = req_json["queryResult"]["outputContexts"]

            for context in output_contexts:
                if context.get("name").endswith("compare-distance"):
                    parsed_req["parsed_zip"] = context.get("parameters").get(
                        "zip-code"
                    )[:3]

            parsed_req["parsed_distance"] = req_json["queryResult"]["parameters"][
                "unit-length"
            ]["amount"]

        return parsed_req

    except Exception as oex:
        logger.error(f"Other Exception parsing request object - {oex}")
        raise


def query_bq(
    logger: logging.Logger, query_string: str, source_zip: str = None, wait: bool = None
) -> bigquery.table.RowIterator:
    """
    Run a query statement in BigQuery.

    :param logger: Logger
    :param source_zip: Zip code to format into query string
    :param wait: Whether or not to wait for result set

    :returns: Newline-delimited string w/ query job results
    """
    try:
        bq_client = bigquery.Client(project=BQ_PROJECT)

        if not wait:
            bq_client.query(
                query_string.format(bq_project=BQ_PROJECT, source_zip=source_zip)
            )

        else:
            query_job = bq_client.query(
                query_string.format(bq_project=BQ_PROJECT, source_zip=source_zip)
            )
            return query_job.result()

    except Exception as oex:
        logger.error(f"Other Exception querying BigQuery - {oex}")
        raise


def populate_uc3_template(
    logger: logging.Logger,
    bq_result_set: bigquery.table.RowIterator,
    parsed_distance: float = None,
) -> dict:
    """
    Populate a Dialogflow fulfillment payload template.
    Currently tuned for use-case 3 here - https://www.mavenwave.com/remi-chatbot/

    :param logger: Logger
    :param bq_result_set: BigQuery results set object
    :param parsed_distance: A distance float value parsed from request object

    :returns: Formatted response template
    """
    try:
        mri_images = [
            "https://www.mavenwave.com/wp-content/uploads/2021/11/mri.jpg",
            "https://www.mavenwave.com/wp-content/uploads/2021/12/mri-2.jpg",
            "https://www.mavenwave.com/wp-content/uploads/2021/12/mri-3.jpg",
        ]
        result_set_rows = bq_result_set.total_rows
        if result_set_rows == 0:
            return UC3_FALLBACK_TEMPLATE

        rich_content = []
        total_mri_cost = 0.0

        for idx, record in enumerate(bq_result_set):
            random_stars = round(random.uniform(3, 5), 1)
            random_distance = round(random.uniform(0.1, parsed_distance), 2)
            #total_mri_cost += round(bq_result_set.interaction_charge) #to pull data from BQ
            random_mri_cost = round(random.uniform(1500,2500), 2)
            total_mri_cost += random_mri_cost
            rich_content.append(
                [
                    {
                        "type": "image",
                        "rawUrl": mri_images[idx],
                        "accessibilityText": record[1],
                    },
                    {
                        "type": "info",
                        "title": f"${random_mri_cost} - {record[1]} - {random_stars} stars",
                        "subtitle": f"{record[2]} - {random_distance} miles away",
                    },
                    {
                        "type": "button",
                        "event": {"name": "", "parameters": {}, "languageCode": ""},
                        "icon": {"color": "#0096d6", "type": "chevron_right"},
                        "link": "tel:8472194294",
                        "text": "Contact office",
                    },
                    {
                        "type": "button",
                        "event": {"name": "", "languageCode": "", "parameters": {}},
                        "icon": {"color": "#0096d6", "type": "chevron_right"},
                        "link": "https://example.com",
                        "text": "Visit website",
                    },
                ]
            )
        rich_content.append(
            [
                {
                    "text": [
                        f"These are the top 3 recommended MRI clinics in your area. The average cost for an MRI in your area is ${round(total_mri_cost / result_set_rows, 2)}."
                    ],
                    "type": "description",
                }
            ]
        )
        rich_content.append(UC3_SEE_MORE)
        rich_content.append(UC3_ADDITIONAL_HELP)
        rich_content.append(UC3_NEXT_STEPS_CHIPS)

        return {"fulfillmentMessages": [{"payload": {"richContent": rich_content}}]}

    except Exception as oex:
        logger.error(oex)
        raise
