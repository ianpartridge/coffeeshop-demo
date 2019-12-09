package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
	"strings"
	"sync"
)

func orderCoffee(baseURL string, orders int, name string, wg *sync.WaitGroup) {
	coffeeURL := baseURL + "/messaging"

	for i := 1; i <= orders; i++ {
		orderName := fmt.Sprintf("%v-%v", name, i)
		orderJSON := fmt.Sprintf("{\"name\": \"%v\", \"product\": \"espresso\"}", orderName)
		resp, err := http.Post(coffeeURL, "application/json", strings.NewReader(orderJSON))
		if err != nil {
			fmt.Printf("Error sending request %v: %v\n", i, err)
			break
		}
		defer resp.Body.Close()
		body, err := ioutil.ReadAll(resp.Body)
		if err != nil {
			fmt.Printf("Error reading body for %v: %v\n", i, err)
			break
		}
		order := Order{}
		json.Unmarshal([]byte(body), &order)
		fmt.Printf("Order %v is: %v\n", i, order)
	}

	wg.Done()
}
