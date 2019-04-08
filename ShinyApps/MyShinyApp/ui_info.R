tabItem_info <- tabItem("tab_info",
                        div(p("[2019/03/26, ver0.1]"),align="right"),
                        div(img(src="bigorb.png", width="75px", height="75px"),align="center"),
                        h1("MyShinyAppテンプレート"),
                        hr(),
                        span(p("一部Login処理が必要な操作があります。"), style="color:red"),
                        span(p("利用後は速やかに管理画面からサーバーを破棄して下さい。"), style="color:red"),
                        hr(),
                        h2("Information"),
                        
                        h3("【カテゴリー01】"),
                        h4("メニュー01"),
                        p("ファイルアップロードサンプル"),
                        br(),
                        h4("メニュー02"),
                        p("xxxサンプル"),
                        p("xxxxxxxxxx"),
                        br(),
                        
                        h3("【カテゴリー02】"),
                        h4("メニュー03"),
                        p("xxxサンプル"),
                        p("xxxxxxxxxx"),
                        br(),
                        
                        h3("【レポートダウンロード】"),
                        p("ファイルダウンロードサンプル"),
                        
                        hr()
)