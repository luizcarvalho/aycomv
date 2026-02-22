  ~                                                                                                                                       46s luiz@aycom
❯ docker exec (docker ps --filter "name=aycomv-web" --format "{{.Names}}" | head -1) bundle exec rake streams:compile date=2026-02-21
Compiling videos for 2026-02-21...
No images found for stream 1 on 2026-02-21
No images found for stream 2 on 2026-02-21
No images found for stream 3 on 2026-02-21
No images found for stream 4 on 2026-02-21
No images found for stream 5 on 2026-02-21
Compiling 740 images for stream 6...
Sending email to record+maximusmano@gmail.com
Error compiling stream 6: Connection refused - connect(2) for "localhost" port 25
  ~                                                                                                                                    1m 38s luiz@aycom
❯ docker exec (docker ps --filter "name=aycomv-web" --format "{{.Names}}" | head -1) bundle exec rake streams:compile date=2026-02-20
Compiling videos for 2026-02-20...
Compiling 870 images for stream 1...
Sending email to ferragistasanta+maximusmano@gmail.com
Error compiling stream 1: Connection refused - connect(2) for "localhost" port 25
Compiling 1033 images for stream 2...
Sending email to ferragistasanta+maximusmano@gmail.com
Error compiling stream 2: Connection refused - connect(2) for "localhost" port 25
Compiling 872 images for stream 3...
Sending email to dramigo+maximusmano@gmail.com
Error compiling stream 3: Connection refused - connect(2) for "localhost" port 25
Compiling 827 images for stream 4...
Sending email to dramigo+maximusmano@gmail.com
Error compiling stream 4: Connection refused - connect(2) for "localhost" port 25
Compiling 870 images for stream 5...
Sending email to armazemparaiba+maximusmano@gmail.com
Error compiling stream 5: Connection refused - connect(2) for "localhost" port 25
Compiling 1440 images for stream 6...
Sending email to record+maximusmano@gmail.com
Error compiling stream 6: Connection refused - connect(2) for "localhost" port 25
  ~                                                                                                                                   11m 11s luiz@aycom