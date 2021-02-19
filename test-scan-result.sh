# isHigh=$(aws ecr describe-image-scan-findings --repository-name dso-repo --image-id imageTag=1.0 --region ap-east-1 | grep "\"severity\": \"HIGH\"") && if [ -z "$isHigh" ]; then echo "Not high"; else echo "$isHigh"; fi

isHigh=$(aws ecr describe-image-scan-findings --repository-name dso-repo --image-id imageTag=1.0 --region ap-east-1 | grep "\"severity\": \"HIGH\"") 
if [ -z "$isHigh" ];
then 
    echo "Not high";
else 
    echo "$isHigh";
fi