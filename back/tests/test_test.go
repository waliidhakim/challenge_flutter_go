// api_test.go
package test

import (
	"testing"
)

func Add(a int, b int) int {
	return a + b
}

func Sub(a int, b int) int {
	return a - b
}

func TestAdd(t *testing.T) {
	result := Add(1, 2)
	expected := 3
	if result != expected {
		t.Errorf("Expected %d, got %d", expected, result)
	}
}

func TestSub(t *testing.T) {
	result := Sub(2, 1)
	expected := 1
	if result != expected {
		t.Errorf("Expected %d, got %d", expected, result)
	}
}
