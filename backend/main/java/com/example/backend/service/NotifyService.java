package com.example.backend.service;

import org.springframework.stereotype.Service;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.sns.SnsClient;
import software.amazon.awssdk.services.sns.model.PublishRequest;
import software.amazon.awssdk.services.sns.model.PublishResponse;

@Service
public class NotifyService {
    public String email(String courseName) {
        System.out.println("EMA");
        SnsClient snsClient = SnsClient.builder().region(Region.US_EAST_1).build();

        String topicArn = "arn:aws:sns:us-east-1:637423441868:MyEmailTestTopic";
        final String subject = "Course Deletion";
        final String msg = "Course with name " + courseName + " has been deleted";
        final PublishRequest publishRequest =
                PublishRequest.builder().topicArn(topicArn).subject(subject).message(msg).build();
        final PublishResponse publishResponse =
                snsClient.publish(publishRequest);

        System.out.println("MessageId: " + publishResponse.messageId());
        System.out.println("Response metadata requestID: " +
                publishResponse.responseMetadata().requestId());
        System.out.println("SDK HTTP response headers: " +
                publishResponse.sdkHttpResponse().headers());
        System.out.println("SDK HTTP response code: " +
                publishResponse.sdkHttpResponse().statusCode() + " " +
                publishResponse.sdkHttpResponse().statusText());

        snsClient.close();
        return "Greetings from Spring Boot!";
    }
}
