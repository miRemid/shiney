package main

import (
	"bytes"
	"io"
	"log"
	"net/http"
	"net/url"
	"path/filepath"
	"regexp"
	"strconv"
	"strings"
	"time"

	"github.com/gin-gonic/gin"
	"rogchap.com/v8go"
)

const (
	PREFIX   = "http://"
	BASE_URL = "www.mangabz.com"
)

var (
	client   http.Client
	bz_cid   *regexp.Regexp
	bz_mid   *regexp.Regexp
	bz_total *regexp.Regexp
	bz_dt    *regexp.Regexp
	bz_sign  *regexp.Regexp

	v8Client *v8go.Context
)

func genHeader(url string) http.Header {
	return http.Header{
		"User-Agent": []string{"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/81.0.4044.138 Safari/537.36"},
		"Referer":    []string{url},
	}
}

func genURL(cid string) string {
	return PREFIX + filepath.Join(BASE_URL, "m"+cid)
}

func init() {
	client = http.Client{
		Timeout: time.Second * 60,
	}

	bz_cid, _ = regexp.Compile(`MANGABZ_CID=(\d*)`)
	bz_mid, _ = regexp.Compile(`MANGABZ_MID=(\d*)`)
	bz_total, _ = regexp.Compile(`MANGABZ_IMAGE_COUNT=(\d*)`)
	bz_dt, _ = regexp.Compile(`MANGABZ_VIEWSIGN_DT="(.*?)";`)
	bz_sign, _ = regexp.Compile(`MANGABZ_VIEWSIGN="(.*?)";`)

	v8Client, _ = v8go.NewContext(nil)
}

type GetImageRequest struct {
	URL string `json:"url" form:"url"`
}

func GetImageURLS(ctx *gin.Context) {
	var req GetImageRequest
	if err := ctx.BindQuery(&req); err != nil {
		ctx.JSON(http.StatusOK, Response{
			Code:    StatusQueryError,
			Message: "参数错误",
		})
		return
	}

	// 1. Get page
	pageURL := req.URL
	conHeader := genHeader(pageURL)
	pageReq, _ := http.NewRequest("GET", pageURL, nil)
	pageReq.Header = conHeader
	res, err := client.Do(pageReq)
	if err != nil {
		log.Println(err)
		ctx.JSON(http.StatusOK, Response{
			Code:    StatusInternalError,
			Message: "内部错误",
		})
		return
	}
	defer res.Body.Close()

	// get params
	var buf bytes.Buffer
	io.Copy(&buf, res.Body)
	var data = buf.String()
	cid := bz_cid.FindStringSubmatch(data)[1]
	mid := bz_mid.FindStringSubmatch(data)[1]
	total := bz_total.FindStringSubmatch(data)[1]
	dt := bz_dt.FindStringSubmatch(data)[1]
	sign := bz_sign.FindStringSubmatch(data)[1]

	// get all images
	var images = []string{}
	pageTotal, _ := strconv.Atoi(total)
	var builder strings.Builder
	for i := 1; i <= pageTotal; i++ {
		builder.Reset()
		builder.WriteString(pageURL)
		builder.WriteString("/chapterimage.ashx?")
		values := url.Values{}
		values.Add("cid", cid)
		values.Add("page", strconv.Itoa(i))
		values.Add("key", "")
		values.Add("_cid", cid)
		values.Add("_mid", mid)
		values.Add("_dt", dt)
		values.Add("_sign", sign)
		builder.WriteString(values.Encode())
		imgreq, _ := http.NewRequest("GET", builder.String(), nil)
		if err != nil {
			log.Println(err)
			ctx.JSON(http.StatusOK, Response{
				Code:    StatusInternalError,
				Message: "内部错误",
			})
			return
		}
		imgreq.Header = conHeader

		imgres, err := client.Do(imgreq)
		if err != nil {
			log.Println(err)
			ctx.JSON(http.StatusOK, Response{
				Code:    StatusInternalError,
				Message: "内部错误",
			})
			return
		}
		defer imgres.Body.Close()
		buf = bytes.Buffer{}
		io.Copy(&buf, imgres.Body)

		val, _ := v8Client.RunScript(string(buf.Bytes()), "main.js")
		imgs := strings.Split(val.String(), ",")
		images = append(images, imgs[0])
	}

	ctx.JSON(http.StatusOK, Response{
		Code: StatusOK,
		Data: images,
	})

}
