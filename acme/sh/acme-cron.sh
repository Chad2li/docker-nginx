#!/bin/bash
# 定时任务调用的脚本入口

source ./profile.sh

# 刷新证书
bash ./acme-new.sh && \
# 部署
bash ./deploy.sh
