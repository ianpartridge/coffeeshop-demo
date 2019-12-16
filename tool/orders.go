package main

import (
	"fmt"
	"sync"
)

var oLock = sync.RWMutex{}
var bLock = sync.RWMutex{}

// Record of orders placed
var _orders map[string][]Order = make(map[string][]Order)

// Record of beverages prepared
var _beverages map[string][]Beverage = make(map[string][]Beverage)

//orders = make(map[string][]Order)
//beverages = make(map[string][]Beverage)

func getAllOrders() []string {
	oLock.RLock()
	defer oLock.RUnlock()
	keys := make([]string, len(_orders))
	i := 0
	for key := range _orders {
		keys[i] = key
		i++
	}
	return keys
}

func getOrders(key string) ([]Order, bool) {
	oLock.RLock()
	defer oLock.RUnlock()
	value, present := _orders[key]
	return value, present
}

func getOrder(key string) Order {
	oLock.RLock()
	defer oLock.RUnlock()
	value, present := _orders[key]
	if present {
		return value[0]
	}
	fmt.Printf("Error - cannot look up order '%v', not present\n", key)
	return Order{}
}

func numOrders(key string) int {
	oLock.RLock()
	defer oLock.RUnlock()
	return len(_orders[key])
}

func setOrder(key string, value Order) {
	oLock.Lock()
	defer oLock.Unlock()
	_orders[key] = []Order{value}
}

func appendOrder(key string, value Order) {
	oLock.Lock()
	defer oLock.Unlock()
	_orders[key] = append(_orders[key], value)
}

func getBeverages(key string) ([]Beverage, bool) {
	bLock.RLock()
	defer bLock.RUnlock()
	value, present := _beverages[key]
	return value, present
}

func numBeverages(key string) int {
	bLock.RLock()
	defer bLock.RUnlock()
	return len(_beverages[key])
}

func setBeverage(key string, value Beverage) {
	bLock.Lock()
	defer bLock.Unlock()
	_beverages[key] = []Beverage{value}
}

func appendBeverage(key string, value Beverage) {
	bLock.Lock()
	defer bLock.Unlock()
	_beverages[key] = append(_beverages[key], value)
}
