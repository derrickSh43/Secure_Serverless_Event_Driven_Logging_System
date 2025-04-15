#  Secure Serverless Event-Driven Logging System
This project implements a secure, event-driven serverless architecture for log ingestion, threat detection, and security escalation using AWS-native services. It emphasizes fine-grained IAM controls, log enrichment, and automated alerting

---

##  What It Is
A fully serverless logging and alerting pipeline built on AW. It ingests logs, processes them in real-time, and routes security events based on severit. The system uses AWS Lambda, EventBridge, CloudWatch, S3, and SNS to deliver a scalable and secure solution for log management and threat detectio.

---

## 💡 Why Use It

- **Security-First Design*: Implements strict IAM policies to prevent unauthorized access and log injectin.
- **Scalability*: Serverless architecture ensures automatic scaling with minimal operational overhed.
- **Real-Time Processing*: Processes logs in real-time, enabling prompt detection and response to security evens.
- **Cost-Effective*: Utilizes AWS's pay-per-use model, reducing costs associated with idle resourcs.
- **Modularity*: Easily extendable to incorporate additional processing steps or integrate with other AWS servics.

---

## 🌟 Key Features

- **Secure Log Ingestion*: Utilizes fine-grained IAM policies to ensure only authorized sources can send lgs.
- **Event-Driven Processing*: Leverages AWS EventBridge to trigger processing functions based on specific evets.
- **Real-Time Alerting*: Sends immediate notifications via SNS when security thresholds are breaced.
- **Centralized Storage*: Stores processed logs in S3 for long-term retention and analyis.
- **Compliance Ready*: Facilitates adherence to security and compliance standards by providing auditable log trals.

---

## 🔁 Main Event Flow

### 1️⃣ Log Submission
A user, system, or application submits logs via **API Gateway**.

### 2️⃣ Request Forwarding
**API Gateway** forwards the request to an AWS **Lambda** function.

### 3️⃣ Log Processing
The **Lambda** function:
- Validates input format
- Optionally enriches the data
- Prepares the log for storage

### 4️⃣ Secure Storage in S3
Logs are stored in an **S3 bucket**:
- Encrypted with **KMS**
- Access restricted via IAM policies

### 5️⃣ S3 → EventBridge Trigger
When a new object is added to the S3 bucket:
- An event is emitted to **Amazon EventBridge**

### 6️⃣ IAM Validation (Security Control Point)
IAM ensures:
- Only this S3 bucket can invoke EventBridge
- EventBridge has permission to forward only trusted events

>  If IAM denies the request, the event is blocked — preventing unauthorized log injection.

##  Architecture


![image](https://github.com/user-attachments/assets/1ae6201d-6987-4235-93fa-13c2dfecb460)




---

##  Directory Structure

```text
.
|-- api.tf
|-- backend
|-- cloudwatch.tf
|-- event_bridge.tf
|-- guide.txt
|-- lambda.tf
|-- lambda_function.py
|-- output.tf
|-- policy.tf
|-- process_logs_lambda.zip
|-- provider.tf
|-- s3.tf
|-- sec_hub.tf
|-- sns.tf
|-- terraform.tfstate
`-- terraform.tfstate.backup
```

---

##  Security Services

|    Service       | Purpose |
|------------------|---------|
| **CloudWatch**   | Logs API Gateway and Lambda activity |
| **GuardDuty**    | Monitors API calls, IAM activity, and network traffic |
| **Security Hub** | Aggregates findings from GuardDuty, IAM, CloudTrail |
| **IAM**          | Enforces role-based access and prevents abuse of EventBridge |

##  Installation & Setup

### Prerequisite

- An AWS account with permissions to create Lambda functions, EventBridge rules, S3 buckets, and SNS toics
- [Terraform](https://www.terraform.io/downloads.html) installed on your local macine
- AWS CLI configured with appropriate credentals.

### Steps

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/derrickSh43/Secure_Serverless_Event_Driven_Logging_System.git
   cd Secure_Serverless_Event_Driven_Logging_System
   ```

2. **Initialize Terraform**:
   ```bash
   terraform init
   ```

3. **Review the Terraform Plan**:
   ```bash
   terraform plan
   ```

4. **Apply the Terraform Configuration**:
   ```bash
   terraform apply
   ```

5. **Deploy Lambda Function**:
   Ensure that the `process_logs_lambda.zip` package is correctly referenced in your Terraform configuration or upload it manually via the AWS Console.

---

##  Common Troubleshooting Steps

- **Lambda Function Errors**
  - Check the Lambda logs in CloudWatch for error mesages.
  - Ensure that the IAM role associated with the Lambda function has the necessary permisions.

- **EventBridge Not Triggering Lambda**
  - Verify that the EventBridge rule is correctly configured and enbled.
  - Ensure that the event pattern matches the incoming eents.

- **Logs Not Appearing in S3**
  - Check the Lambda function's code to ensure it correctly writes to the specified S3 bcket.
  - Verify that the S3 bucket exists and the Lambda function has write permisions.

- **SNS Alerts Not Received**
  - Confirm that the SNS topic is correctly configured and that subscriptions are confrmed.
  - Check CloudWatch metrics to see if the SNS topic is receiving mesages.

---

##  License

This project is licensed under the [MIT License](LIENSE).
