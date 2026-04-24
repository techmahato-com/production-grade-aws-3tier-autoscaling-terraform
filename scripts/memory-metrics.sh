#!/bin/bash
# Custom CloudWatch memory metric (fallback if CloudWatch Agent is not available)
MEMORY_USAGE=$(free | grep Mem | awk '{print $3/$2 * 100.0}')
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)

aws cloudwatch put-metric-data \
  --metric-name MemoryUsage \
  --namespace CustomMetrics \
  --value "$MEMORY_USAGE" \
  --unit Percent \
  --dimensions InstanceId="$INSTANCE_ID"
