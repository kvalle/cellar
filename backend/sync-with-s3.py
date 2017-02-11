# encoding: utf-8

import os
import os.path

import boto3
import botocore

import config


files_path = os.path.dirname(os.path.realpath(__file__)) + "/data/"
files = [f for f in os.listdir(files_path) 
           if os.path.isfile(os.path.join(files_path, f))
           if f.endswith(".json")]


s3 = boto3.Session(
    aws_access_key_id=config.s3_access_key,
    aws_secret_access_key=config.s3_access_secret,
    region_name=config.s3_region
).resource(
    's3',
    config=botocore.client.Config(signature_version='s3v4')
)


def store_to_s3(key, data):
    bucket = s3.Bucket(config.s3_bucket_name)
    bucket.put_object(Key="beers/" + key, Body=data)


def load_from_file(file):
    with open(files_path + file, "r") as f:
        return "".join(f.readlines())


def list_objects():
  bucket = s3.Bucket(config.s3_bucket_name)
  for obj in bucket.objects.all():
      print(obj)


if __name__ == "__main__":
    for file in files:
        store_to_s3(file, load_from_file(file))

    list_objects()
