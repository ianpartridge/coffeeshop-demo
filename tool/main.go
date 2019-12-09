package main

import (
	"flag"
)

// Order is a coffee order placed with the coffeeshop-service
type Order struct {
	Name    string
	Product string
	OrderID string
}

// Beverage is a product produced by a barista
type Beverage struct {
	Beverage   string
	Customer   string
	OrderID    string
	PreparedBy string
}

// Fulfillment is the completion of an order with a beverage
type Fulfillment struct {
	Beverage Beverage
	Order    Order
	State    string
}

func main() {
	baseURL := flag.String("url", "http://localhost:8080", "The base URL of the coffeeshop-service")
	orders := flag.Int("orders", 5, "Number of orders to place")
	order := flag.Bool("order", false, "Orders should be placed")
	consume := flag.Bool("monitor", false, "Queue should be monitored")
	flag.Parse()

	if *order {
		orderCoffee(*baseURL, *orders)
	}
	if *consume {
		consumeCoffee(*baseURL)
	}
}
