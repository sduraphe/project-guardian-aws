# Project Guardian: A SOC2-Compliant Document Processing Pipeline on AWS

This repository contains the infrastructure and application code for Project Guardian, a secure, automated document processing pipeline built entirely on AWS using DevOps best practices. The project is designed to mirror a real-world, high-compliance environment suitable for a SOC2-audited system.

The pipeline ingests a document through a secure API, stores it in a locked-down S3 bucket, and queues it for asynchronous processing by a serverless function, with full auditability and monitoring.



---

## 🚀 Key Features & DevOps Concepts Demonstrated

* **Secure Infrastructure as Code (IaC):** The entire AWS environment is defined and managed using **Terraform**, ensuring a repeatable, version-controlled, and auditable setup.
* **Automated CI Pipeline:** A CI pipeline using **AWS CodePipeline** and **CodeBuild** automatically builds, tests, and scans the application on every `git push`.
* **"Shift-Left" Security (DevSecOps):** The CI pipeline includes a mandatory vulnerability scan using **Trivy**. A build will fail if any `HIGH` or `CRITICAL` vulnerabilities are found in the container image.
* **Zero-Downtime Deployments:** The application is deployed to **Amazon ECS on Fargate** using a rolling update strategy, ensuring the API is always available even during updates.
* **Serverless, Event-Driven Backend:** Uses **SQS** and **Lambda** to create a decoupled, scalable, and resilient backend for processing documents asynchronously.
* **High Availability & Resilience:** The ECS service runs a minimum of two application instances in different availability zones, managed by an Application Load Balancer.
* **Comprehensive Observability:** All application and service logs are centralized in **CloudWatch Logs**, and the infrastructure is set up for monitoring and alerting.

---

## 🛠️ Tech Stack

| Category                  | Technology                                                              |
| ------------------------- | ----------------------------------------------------------------------- |
| **Cloud Provider** | AWS (Amazon Web Services)                                               |
| **Infrastructure as Code**| Terraform                                                               |
| **CI/CD** | AWS CodePipeline, AWS CodeBuild, AWS CodeCommit                         |
| **Containerization** | Docker, Amazon ECR                                                      |
| **Orchestration** | Amazon ECS on AWS Fargate                                               |
| **Application Code** | Python (Flask)                                                          |
| **Serverless & Messaging**| AWS Lambda, Amazon SQS                                                  |
| **Storage & Database** | Amazon S3, Amazon DynamoDB                                              |
| **Security & Compliance** | AWS IAM (Least Privilege), AWS Secrets Manager, Trivy, AWS CloudTrail |
| **Monitoring** | Amazon CloudWatch                                                       |

---

## ⚙️ How to Run

**Note:** This project has been torn down to save costs. The following steps outline the process to recreate the environment.

1.  **Configure AWS Credentials:** Ensure your local machine is configured with AWS credentials that have sufficient permissions.
2.  **Deploy the Infrastructure:** Navigate to the root of the project and run the Terraform commands:
    ```bash
    terraform init
    terraform apply
    ```
3.  **Set Up the CI/CD Pipeline:** Manually create the CodeCommit repo, CodeBuild project, and CodePipeline in the AWS Console, connecting them as described in the project plan.
4.  **Push the Application Code:** Push the `app` directory to the CodeCommit repository. This will trigger the CI pipeline, which will build the Docker image and push it to ECR.
5.  **Run the Final Deployment:** The `terraform apply` in Step 2 will have deployed the ECS service. Once the pipeline has pushed the initial image, the ECS service will pull it and the application will become available at the `application_url` provided in the Terraform output.