import boto3
import botocore

import config

s3 = boto3.Session(
   aws_access_key_id=config.s3_access_key,
   aws_secret_access_key=config.s3_access_secret
).resource('s3')


def store(user_id, beers):
    bucket = s3.Bucket(config.s3_bucket_name)
    bucket.put_object(Key="beers/" + user_id + ".json", Body=beers)


def load(user_id):
    try:
        obj = s3.Object(config.s3_bucket_name, "beers/" + user_id + ".json")
        return obj.get()['Body'].read().decode('utf-8') 
    except botocore.exceptions.ClientError as e:
        if e.response["Error"]["Code"] == "NoSuchKey":
            return "[]"
        else:
            raise e

