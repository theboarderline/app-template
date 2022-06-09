from random import randint

# Used to append to messages to twilio texts
stop_msg = '\nPlease reply STOP if you wish to stop receiving texts from us'


def intro_text(name):
    msg = f'Good Morning {name}!'
    return msg + stop_msg
