import sys
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
from awsglue.utils import getResolvedOptions
from awsglue.dynamicframe import DynamicFrame
from awsglue.transforms import ApplyMapping

job_params = [
    'JOB_NAME',
]

args = getResolvedOptions(sys.argv, job_params)

JOB_NAME = args['JOB_NAME']

# ローカルs3を対象にするため、hadoopにendpointの設定を行う
sc = SparkContext()
sc._jsc.hadoopConfiguration().set("fs.s3a.endpoint", "http://localstack:4566")
sc._jsc.hadoopConfiguration().set("fs.s3a.path.style.access", "true")
sc._jsc.hadoopConfiguration().set("fs.s3a.signing-algorithm", "S3SignerType")

glue_context = GlueContext(sc)
spark = glue_context.spark_session
job = Job(glue_context)
job.init(JOB_NAME, args)

S3bucketSample = glue_context.create_dynamic_frame.from_options(
    format_options={"quoteChar": '"', "withHeader": True, "separator": ","},
    connection_type="s3",
    format="csv",
    connection_options={
        "paths": ["s3a://test-csv/sample.csv"]
    },
)

ApplyMappingfromSample = ApplyMapping.apply(
    frame=S3bucketSample,
    mappings=[
        ("id", "int", "id", "int"),
        ("name", "string", "name", "string"),
    ],
)

glue_context.write_dynamic_frame.from_options(
    frame=S3bucketSample,
    connection_type="s3",
    connection_options={
        "path": "s3a://test-csv/write/"
    },
    format='csv',
)

job.commit()
