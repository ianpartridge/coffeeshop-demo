package main

import (
	"encoding/json"
	"fmt"
	"sync"
	"time"

	"github.com/r3labs/sse"
)

func monitorOrders(wg *sync.WaitGroup) {
	for {
		<-time.After(10 * time.Second)
		go printOrders()
	}
}

func printOrders() {
	orders := getAllOrders()
	fmt.Println("Order status:")
	for order := range orders {
		beverageCount := numBeverages(orders[order])
		orderDetails := getOrder(orders[order])
		fmt.Printf("%v for %v: completions %v\n", orderDetails.Product, orderDetails.Name, beverageCount)
	}
}

func consumeCoffee(baseURL string, wg *sync.WaitGroup) {
	queueURL := baseURL + "/queue"

	client := sse.NewClient(queueURL)
	client.SubscribeRaw(consumeEvent)

	wg.Done()
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
		existingOrder, present := getOrders(order.OrderID)
		if !present {
			setOrder(order.OrderID, order)
		} else {
			fmt.Printf("ERROR: duplicate order:\n  - new order: %v\n  - existing order: %v\n", order, existingOrder)
			appendOrder(order.OrderID, order)
			fmt.Printf(" - total requests for this order: %v\n", numOrders(order.OrderID))
		}
	case "READY":
		barista := beverage.PreparedBy
		fmt.Printf("Beverage for %v is ready: prepared by %v\n", order.Name, barista)
		existingBeverage, present := getBeverages(order.OrderID)
		if !present {
			setBeverage(order.OrderID, beverage)
		} else {
			fmt.Printf("ERROR: duplicate beverage:\n  - new beverage: %v\n  - existing beverage: %v\n", beverage, existingBeverage)
			appendBeverage(order.OrderID, beverage)
			fmt.Printf(" - total completions for this order: %v\n", numBeverages(order.OrderID))
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
