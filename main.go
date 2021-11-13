package main

import (
	"encoding/json"
	"net/http"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
)

type Event struct {
	Name string `json:"name"`
}

func handleRequest(req events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	name, ok := req.QueryStringParameters["name"]
	if !ok {
		name = "blank"
	}
	j, err := json.Marshal(map[string]string{"event": name})
	if err != nil {
		res := events.APIGatewayProxyResponse{
			StatusCode: http.StatusBadRequest,
		}
		return res, nil
	}

	res := events.APIGatewayProxyResponse{
		StatusCode: http.StatusOK,
		Headers:    map[string]string{"Content-Type": "application/json; charset=utf-8"},
		Body:       string(j),
	}
	return res, nil
}

func main() {
	lambda.Start(handleRequest)
}
