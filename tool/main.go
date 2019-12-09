package main

import (
	"flag"
	"sync"
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
	name := flag.String("name", "Demo", "Name of person ordering coffee")
	consume := flag.Bool("monitor", false, "Queue should be monitored")
	flag.Parse()

	var wg sync.WaitGroup

	if *order {
		wg.Add(1)
		go orderCoffee(*baseURL, *orders, *name, &wg)
	}
	if *consume {
		wg.Add(1)
		consumeCoffee(*baseURL, &wg)
	}

	wg.Wait()
}
