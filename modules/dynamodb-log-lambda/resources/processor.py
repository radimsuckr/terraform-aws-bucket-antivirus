import json
import logging
from os import getenv

import boto3
import sentry_sdk
from sentry_sdk.integrations.aws_lambda import AwsLambdaIntegration

logger = logging.getLogger(__name__)

DDB_TABLE = getenv('DYNAMODB_TABLE')
if not DDB_TABLE:
    raise ValueError('Set "DYNAMODB_TABLE" environment variable')
AV_SIGNATURE_FIELD_NAME = getenv('AV_SIGNATURE_FIELD_NAME')
if not AV_SIGNATURE_FIELD_NAME:
    raise ValueError('Set "AV_SIGNATURE_FIELD_NAME" environment variable')
AV_STATUS_FIELD_NAME = getenv('AV_STATUS_FIELD_NAME')
if not AV_STATUS_FIELD_NAME:
    raise ValueError('Set "AV_STATUS_FIELD_NAME" environment variable')
AV_TIMESTAMP_FIELD_NAME = getenv('AV_TIMESTAMP_FIELD_NAME')
if not AV_TIMESTAMP_FIELD_NAME:
    raise ValueError('Set "AV_TIMESTAMP_FIELD_NAME" environment variable')
AV_SCAN_START_FIELD_NAME = getenv('AV_SCAN_START_FIELD_NAME')
if not AV_SCAN_START_FIELD_NAME:
    raise ValueError('Set "AV_SCAN_START_FIELD_NAME" environment variable')
INFECTED_STATUS = getenv('INFECTED_STATUS')
if not INFECTED_STATUS:
    raise ValueError('Set "INFECTED_STATUS" environment variable')
SENTRY_DSN = getenv('SENTRY_DSN')
if SENTRY_DSN:
    sentry_sdk.init(
        dsn=SENTRY_DSN,
        integrations=[
            AwsLambdaIntegration(timeout_warning=True),
        ],
        # Set traces_sample_rate to 1.0 to capture 100% of transactions for performance monitoring.
        # We recommend adjusting this value in production,
        # traces_sample_rate=1.0,
    )
else:
    logger.info('Sentry DSN not set')


def handler(event, context):
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table(DDB_TABLE)

    message = event['Records'][0]
    if message['EventVersion'] != '1.0':
        logger.warn('EventVersion is not "1.0"')

    # https://github.com/bluesentry/bucket-antivirus-function/blob/0e86c59ad259b266754f2647ed702fbcb9c216c4/scan.py#L181-L200
    sns_message = json.loads(message['Sns']['Message'])
    if sns_message[AV_STATUS_FIELD_NAME] != INFECTED_STATUS:
        return  # Object is not infected
    if AV_SCAN_START_FIELD_NAME in sns_message.keys():
        logger.info('Received a scan start notification. Ignoring.')
        return

    table.put_item(
        Item={
            's3_uri': f's3://{sns_message["bucket"]}/{sns_message["key"]}',
            'version': 'null' if not sns_message['version'] else sns_message['version'],
            'signature': sns_message[AV_SIGNATURE_FIELD_NAME],
            'timestamp': sns_message[AV_TIMESTAMP_FIELD_NAME],
        },
    )
