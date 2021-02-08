package main

const (
	StatusOK = 0 + iota
	StatusInternalError
	StatusQueryError
	StatusGetImageError
)

type Response struct {
	Code    int         `json:"code"`
	Data    interface{} `json:"data"`
	Message string      `json:"messgae"`
}
