from server import settings
from django.conf import settings
from twilio.rest import Client

from .text_messages import intro_text


def clean_number(phone_number):
    return phone_number.replace("(", "").replace(")", "").replace("-", "").replace(" ", "")


def is_valid_number(phone_number):
    try:
        int(phone_number)
    except TypeError:
        print('INVALID PHONE NUMBER: Expecting number')

    return True if len(phone_number) == 10 else False


def send_text(number, twilio_number, msg):
    client = Client(settings.TWILIO_ACCOUNT_SID, settings.TWILIO_AUTH_TOKEN)
    client.messages.create(
        to=clean_number(number), from_=twilio_number, body=msg
    )


def send_intro_text(member):
    send_text(member['phone'], settings.TWILIO_NUMBER,
              intro_text(member['user'].first_name))
