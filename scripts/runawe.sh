KB_TOP=/mnt/ubuntu/awe_service_distribution/deployment
source $KB_TOP/user-env.sh
nohup awe-client -conf $KB_TOP/services/awe_service/conf/awec.cfg &
