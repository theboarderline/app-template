DEMO_RUNNER_ZIP_CODE = "606"

WARMP_UP_INTENTS = {
    "1.2-Schedule": {
        "template": {
            "fulfillmentMessages": [
                {
                    "payload": {
                        "richContent": [
                            [
                                {
                                    "type": "description",
                                    "text": [
                                        "I am happy to help you find a clinic, where would you like to search?"
                                    ],
                                }
                            ],
                            [
                                {
                                    "type": "chips",
                                    "options": [
                                        {"link": "", "text": "Near me", "image": {}},
                                        {"link": "", "image": {}, "text": "Near home"},
                                        {"image": {}, "text": "Near work", "link": ""},
                                        {
                                            "image": {},
                                            "text": "Last visited",
                                            "link": "",
                                        },
                                        {
                                            "image": {},
                                            "text": "Enter city or zip",
                                            "link": "",
                                        },
                                    ],
                                }
                            ],
                        ]
                    }
                }
            ]
        }
    },
    "2.2-Find-Doctor": {
        "template": {
            "fulfillmentMessages": [
                {
                    "payload": {
                        "richContent": [
                            [
                                {
                                    "text": [
                                        "Is there a specific type of therapy you are looking for?"
                                    ],
                                    "type": "description",
                                }
                            ],
                            [
                                {
                                    "options": [
                                        {
                                            "image": {},
                                            "link": "",
                                            "text": "Neurological",
                                        },
                                        {"link": "", "image": {}, "text": "Orthopedic"},
                                        {
                                            "link": "",
                                            "image": {},
                                            "text": "Cardiovascular",
                                        },
                                        {"text": "Other", "image": {}, "link": ""},
                                    ],
                                    "type": "chips",
                                }
                            ],
                        ]
                    }
                }
            ]
        }
    },
    "3.2-Compare": {
        "template": {
            "fulfillmentMessages": [
                {
                    "payload": {
                        "richContent": [
                            [
                                {
                                    "text": ["What type of MRI are you looking for?"],
                                    "type": "description",
                                }
                            ],
                            [
                                {
                                    "options": [
                                        {"link": "", "text": "Abdominal", "image": {}},
                                        {"link": "", "text": "Brain", "image": {}},
                                        {"link": "", "image": {}, "text": "Spine"},
                                        {"link": "", "text": "Other", "image": {}},
                                    ],
                                    "type": "chips",
                                }
                            ],
                        ]
                    }
                }
            ]
        }
    },
}


UC3_DISTANCE = {
    "fulfillmentMessages": [
        {
            "payload": {
                "richContent": [
                    [
                        {
                            "text": ["How far would you be able to travel?"],
                            "type": "description",
                        }
                    ],
                    [
                        {
                            "type": "chips",
                            "options": [
                                {"image": {}, "link": "", "text": "5 Miles"},
                                {"image": {}, "link": "", "text": "10 Miles"},
                                {"image": {}, "link": "", "text": "15 Miles"},
                                {"image": {}, "link": "", "text": "20 Miles"},
                            ],
                        }
                    ],
                ]
            }
        }
    ]
}
UC3_RICH_TEMPLATE = {"fulfillmentMessages": [{"payload": {"richContent": None}}]}
UC3_FALLBACK_TEMPLATE = {
    "fulfillmentMessages": [
        {
            "payload": {
                "richContent": [
                    [
                        {
                            "text": [
                                "I'm sorry, but I couldn't find any available providers in your area. Here's where we'd do something else."
                            ],
                            "type": "description",
                        }
                    ],
                ]
            }
        }
    ]
}
UC3_SEE_MORE = [
    {
        "options": [{"text": "See More", "link": "", "image": {}}],
        "type": "chips",
    }
]
UC3_ADDITIONAL_HELP = [
    {
        "text": [" Is there anything else I can help you with?"],
        "type": "description",
    }
]
UC3_NEXT_STEPS_CHIPS = [
    {
        "type": "chips",
        "options": [
            {"link": "", "image": {}, "text": "Find a doctor"},
            {
                "image": {},
                "link": "",
                "text": "Schedule an appointment",
            },
            {"link": "", "text": "No, thank you", "image": {}},
        ],
    }
]
"""
USE_CASE_3_RICH_TEMPLATE = {
    "fulfillmentMessages": [
        {
            "payload": {
                "richContent": [
                    [
                        {
                            "type": "image",
                            "rawUrl": "https://www.mavenwave.com/wp-content/uploads/2021/11/mri.jpg",
                            "accessibilityText": "SIRESHA CHALUVADI",
                        },
                        {
                            "type": "info",
                            "title": "$1400.23 - SIRESHA CHALUVADI - some Stars",
                            "subtitle": "8 S MICHIGAN AVE SUITE 1505, CHICAGO, IL, 60603 - 5 miles away",
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
                    ],
                    [
                        {
                            "type": "image",
                            "rawUrl": "https://www.mavenwave.com/wp-content/uploads/2021/11/mri.jpg",
                            "accessibilityText": "HILLIARD SLAVICK",
                        },
                        {
                            "type": "info",
                            "title": "$1400.23 - HILLIARD SLAVICK - some Stars",
                            "subtitle": "8 S MICHIGAN AVE SUITE 1505, CHICAGO, IL, 60603 - 5 miles away",
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
                    ],
                    [
                        {
                            "type": "image",
                            "rawUrl": "https://www.mavenwave.com/wp-content/uploads/2021/11/mri.jpg",
                            "accessibilityText": "NORMAN KOHN",
                        },
                        {
                            "type": "info",
                            "title": "$1400.23 - NORMAN KOHN - some Stars",
                            "subtitle": "122 S MICHIGAN AVE SUITE 1300, CHICAGO, IL, 60603 - 5 miles away",
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
                    ],
                    [
                        {
                            "options": [{"text": "See More", "link": "", "image": {}}],
                            "type": "chips",
                        }
                    ],
                    [
                        {
                            "text": [" Is there anything else I can help you with?"],
                            "type": "description",
                        }
                    ],
                    [
                        {
                            "type": "chips",
                            "options": [
                                {"link": "", "image": {}, "text": "Find a doctor"},
                                {
                                    "image": {},
                                    "link": "",
                                    "text": "Schedule an appointment",
                                },
                                {"link": "", "text": "No, thank you", "image": {}},
                            ],
                        }
                    ],
                ]
            }
        }
    ]
}
"""
