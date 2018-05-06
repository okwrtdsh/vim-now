package main

import (
	"encoding/json"
	"flag"
	"log"
	"net"
	"time"
)

func main() {
	var port string
	flag.StringVar(&port, "p", "8765", "Port")
	flag.Parse()

	l, err := net.Listen("tcp", ":"+port)
	if err != nil {
		log.Fatal(err)
	}
	for {
		conn, err := l.Accept()
		if err != nil {
			continue
		}
		go func(conn net.Conn) {
			defer conn.Close()
			var buf [1024]byte

			len, err := conn.Read(buf[:])
			if err != nil {
				log.Println(err)
				return
			}

			// rcv: [channel_id, msg]
			var v [2]interface{}

			err = json.Unmarshal(buf[:len], &v)
			if err != nil {
				log.Println(err)
				return
			}

			for {
				// snd: [-channel_id, msg]
				if id, ok := v[0].(float64); ok && id > 0 {
					v[0] = -id
				}
				v[1] = time.Now().Format("2006-01-02 03:04:05 -0700 MST")

				// send to vim
				err = json.NewEncoder(conn).Encode(v)
				if err != nil {
					// log.Println(err)
					break
				}

				time.Sleep(1 * time.Second)
			}
		}(conn)
	}
}
