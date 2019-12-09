package main

import (
	"encoding/json"
	"fmt"

	"github.com/r3labs/sse"
)

// Record of orders placed
var orders map[string][]Order

// Record of beverages prepared
var beverages map[string][]Beverage

func consumeCoffee(baseURL string) {
	queueURL := baseURL + "/queue"

	orders = make(map[string][]Order)
	beverages = make(map[string][]Beverage)

	client := sse.NewClient(queueURL)
	client.SubscribeRaw(consumeEvent)
}

func consumeEvent(msg *sse.Event) {
	// All events on the queue should be in the Fulfillment format. They may or
	// may not contain a Beverage.
	fulfillment := Fulfillment{}
	json.Unmarshal(msg.Data, &fulfillment)

	state := fulfillment.State
	order := fulfillment.Order
	beverage := fulfillment.Beverage

	switch state {
	case "IN_QUEUE":
		fmt.Printf("%v has ordered a %v: orderId=%v\n", order.Name, order.Product, order.OrderID)
		existingOrder, present := orders[order.OrderID]
		if !present {
			orders[order.OrderID] = []Order{order}
		} else {
			fmt.Printf("ERROR: duplicate order:\n  - new order: %v\n  - existing order: %v\n", order, existingOrder)
			orders[order.OrderID] = append(orders[order.OrderID], order)
			fmt.Printf(" - total requests for this order: %v\n", len(orders[order.OrderID]))
		}
	case "READY":
		barista := beverage.PreparedBy
		fmt.Printf("Beverage for %v is ready: prepared by %v\n", order.Name, barista)
		existingBeverage, present := beverages[order.OrderID]
		if !present {
			beverages[order.OrderID] = []Beverage{beverage}
		} else {
			fmt.Printf("ERROR: duplicate beverage:\n  - new beverage: %v\n  - existing beverage: %v\n", beverage, existingBeverage)
			beverages[order.OrderID] = append(beverages[order.OrderID], beverage)
			fmt.Printf(" - total completions for this order: %v\n", len(beverages[order.OrderID]))
		}
		// Consistency checks
		if beverage.Customer != order.Name {
			fmt.Printf("ERROR: Customer name does not match order: Order name=%v, Beverage customer=%v\n", order.Name, beverage.Customer)
		}
		if beverage.OrderID != order.OrderID {
			fmt.Printf("ERROR: Order IDs do not match: Order=%v, Beverage=%v\n", order.OrderID, beverage.OrderID)
		}
	default:
		fmt.Printf("ERROR: Unknown state: %v", state)
	}
}
