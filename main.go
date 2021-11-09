package main

import (
	"context"
	"fmt"

	"github.com/aws/aws-lambda-go/lambda"
)

type Event struct {
	Name string `json:"name"`
}

func HandleRequest(ctx context.Context, e Event) (string, error) {
	return fmt.Sprintf("Event: %s", e.Name), nil
}

func main() {
	lambda.Start(HandleRequest)
}
