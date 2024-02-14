# The Documentation Practics


본 문서는 코딩 따라하기 테스트 페이지, 제가 다른 문서를 참조해서 따라해보는 페이지 입니다.


## 1. NGINX &#43; PHP &#43; MYSQL 연동

환경
* UBUNTU: VERSION=&#34;20.04.3 LTS (Focal Fossa)&#34;
* MYSQL: mysql  Ver 8.0.28 for Linux on x86_64 (MySQL Community Server - GPL)
* PHP: PHP 7.4.3 (cli) (built: Nov 25 2021 23:16:22) ( NTS )
* NGINX: nginx version: nginx/1.20.2
---
사전 지식
* NGINX
* MYSQL
* PHP

#### PDO
PDO(PHP Data Objects)란 여러가지 데이터베이스를 제어하는 방법을 표준화시킨 것이다. 데이터베이스는 다양한 종류가 있다. 그리고 종류에 따라서 서로 다른 드라이브를 사용해 왔는데 드라이브의 종류에 따라서 데이터베이스를 제어하기 위한 API가 달랐다. PDO를 사용하면 동일한 방법으로 데이터베이스를 제어할 수 있다.

PDO를 사용하기 위해서는

```shell
## 해당 파일에서
vi /etc/php/7.4/fpm/php.ini

## 아래 pdo_mysql 주석을 제거 한다.
;extension=pdo_firebird
extension=pdo_mysql
;extension=pdo_oci
;extension=pdo_odbc
;extension=pdo_pgsql
;extension=pdo_sqlite
```

{{&lt; admonition example &#34;mysql 사전 작업&#34; &gt;}}
```shell
## 데이터베이스(스키마) 생성
CREATE DATABASE opentutorials CHARACTER SET utf8 COLLATE utf8_general_ci;

## 설정 할 스키마 선택
use opentutorials;

## TABLE 생성
CREATE TABLE topic (
    id  int(11) NOT NULL AUTO_INCREMENT,
    title  varchar(255) NOT NULL ,
    description  text NULL ,
    created  datetime NOT NULL ,
    PRIMARY KEY (id)
);
```
{{&lt; /admonition &gt;}}

{{&lt; admonition example &#34;PHP 구성&#34; &gt;}}
input.php
```php
&lt;!DOCTYPE html&gt;
&lt;html&gt;
    &lt;head&gt;
        &lt;meta charset=&#34;utf-8&#34;/&gt;
    &lt;/head&gt;
    &lt;body&gt;
        &lt;form action=&#34;./process.php?mode=insert&#34; method=&#34;POST&#34;&gt;
            &lt;p&gt;제목 : &lt;input type=&#34;text&#34; name=&#34;title&#34;&gt;&lt;/p&gt;
            &lt;p&gt;본문 : &lt;textarea name=&#34;description&#34; id=&#34;&#34; cols=&#34;30&#34; rows=&#34;10&#34;&gt;&lt;/textarea&gt;&lt;/p&gt;
            &lt;p&gt;&lt;input type=&#34;submit&#34; /&gt;&lt;/p&gt;
        &lt;/form&gt;
    &lt;/body&gt;
&lt;/html&gt;
```
process.php
```php
&lt;?php
$dbh = new PDO(&#39;mysql:host=localhost;dbname=opentutorials&#39;, &#39;root&#39;, &#39;111111&#39;, array(PDO::MYSQL_ATTR_INIT_COMMAND =&gt; &#34;SET NAMES utf8&#34;));
switch($_GET[&#39;mode&#39;]){
    case &#39;insert&#39;:
        $stmt = $dbh-&gt;prepare(&#34;INSERT INTO topic (title, description, created) VALUES (:title, :description, now())&#34;);
        $stmt-&gt;bindParam(&#39;:title&#39;,$title);
        $stmt-&gt;bindParam(&#39;:description&#39;,$description);
 
        $title = $_POST[&#39;title&#39;];
        $description = $_POST[&#39;description&#39;];
        $stmt-&gt;execute();
        header(&#34;Location: list.php&#34;); 
        break;
    case &#39;delete&#39;:
        $stmt = $dbh-&gt;prepare(&#39;DELETE FROM topic WHERE id = :id&#39;);
        $stmt-&gt;bindParam(&#39;:id&#39;, $id);
 
        $id = $_POST[&#39;id&#39;];
        $stmt-&gt;execute();
        header(&#34;Location: list.php&#34;); 
        break;
    case &#39;modify&#39;:
        $stmt = $dbh-&gt;prepare(&#39;UPDATE topic SET title = :title, description = :description WHERE id = :id&#39;);
        $stmt-&gt;bindParam(&#39;:title&#39;, $title);
        $stmt-&gt;bindParam(&#39;:description&#39;, $description);
        $stmt-&gt;bindParam(&#39;:id&#39;, $id);
 
        $title = $_POST[&#39;title&#39;];
        $description = $_POST[&#39;description&#39;];
        $id = $_POST[&#39;id&#39;];
        $stmt-&gt;execute();
        header(&#34;Location: list.php?id={$_POST[&#39;id&#39;]}&#34;);
        break;
}
?&gt;
```
list.php
```php
&lt;?php
$dbh = new PDO(&#39;mysql:host=localhost;dbname=opentutorials&#39;, &#39;root&#39;, &#39;111111&#39;);
$stmt = $dbh-&gt;prepare(&#39;SELECT * FROM topic&#39;);
$stmt-&gt;execute();
$list = $stmt-&gt;fetchAll();
if(!empty($_GET[&#39;id&#39;])) {
    $stmt = $dbh-&gt;prepare(&#39;SELECT * FROM topic WHERE id = :id&#39;);
    $stmt-&gt;bindParam(&#39;:id&#39;, $id, PDO::PARAM_INT);
    $id = $_GET[&#39;id&#39;];
    $stmt-&gt;execute();
    $topic = $stmt-&gt;fetch();
}
?&gt;
&lt;!DOCTYPE html&gt;
&lt;html&gt;
    &lt;head&gt;
        &lt;meta charset=&#34;utf-8&#34; /&gt;
        &lt;style type=&#34;text/css&#34;&gt;
            body {
                font-size: 0.8em;
                font-family: dotum;
                line-height: 1.6em;
            }
            header {
                border-bottom: 1px solid #ccc;
                padding: 20px 0;
            }
            nav {
                float: left;
                margin-right: 20px;
                min-height: 1000px;
                min-width:150px;
                border-right: 1px solid #ccc;
            }
            nav ul {
                list-style: none;
                padding-left: 0;
                padding-right: 20px;
            }
            article {
                float: left;
            }
            .description{
                width:500px;
            }
        &lt;/style&gt;
    &lt;/head&gt;
   
    &lt;body id=&#34;body&#34;&gt;
        &lt;div&gt;
            &lt;nav&gt;
                &lt;ul&gt;
                    &lt;?php
                    foreach($list as $row) {
                        echo &#34;&lt;li&gt;&lt;a href=\&#34;?id={$row[&#39;id&#39;]}\&#34;&gt;&#34;.htmlspecialchars($row[&#39;title&#39;]).&#34;&lt;/a&gt;&lt;/li&gt;&#34;;                        }
                    ?&gt;
                &lt;/ul&gt;
                &lt;ul&gt;
                    &lt;li&gt;&lt;a href=&#34;input.php&#34;&gt;추가&lt;/a&gt;&lt;/li&gt;
                &lt;/ul&gt;
            &lt;/nav&gt;
            &lt;article&gt;
                &lt;?php
                if(!empty($topic)){
                ?&gt;
                &lt;h2&gt;&lt;?=htmlspecialchars($topic[&#39;title&#39;])?&gt;&lt;/h2&gt;
                &lt;div class=&#34;description&#34;&gt;
                    &lt;?=htmlspecialchars($topic[&#39;description&#39;])?&gt;
                &lt;/div&gt;
                &lt;div&gt;
                    &lt;a href=&#34;modify.php?id=&lt;?=$topic[&#39;id&#39;]?&gt;&#34;&gt;수정&lt;/a&gt;
                    &lt;form method=&#34;POST&#34; action=&#34;process.php?mode=delete&#34;&gt;
                        &lt;input type=&#34;hidden&#34; name=&#34;id&#34; value=&#34;&lt;?=$topic[&#39;id&#39;]?&gt;&#34; /&gt;
                        &lt;input type=&#34;submit&#34; value=&#34;삭제&#34; /&gt;
                    &lt;/form&gt;
                &lt;/div&gt;
                &lt;?php
                }
                ?&gt;
            &lt;/article&gt;
        &lt;/div&gt;
    &lt;/body&gt;
&lt;/html&gt;
```

modify.php
```php
&lt;?php
$dbh = new PDO(&#39;mysql:host=localhost;dbname=opentutorials&#39;, &#39;root&#39;, &#39;111111&#39;);
$stmt = $dbh-&gt;prepare(&#39;SELECT * FROM topic WHERE id = :id&#39;);
$stmt-&gt;bindParam(&#39;:id&#39;, $id, PDO::PARAM_INT);
$id = $_GET[&#39;id&#39;];
$stmt-&gt;execute();
$topic = $stmt-&gt;fetch();
?&gt;
&lt;!DOCTYPE html&gt;
&lt;html&gt;
    &lt;head&gt;
        &lt;meta charset=&#34;utf-8&#34;/&gt;
    &lt;/head&gt;   
    &lt;body&gt;
        &lt;form action=&#34;./process.php?mode=modify&#34; method=&#34;POST&#34;&gt;
            &lt;input type=&#34;hidden&#34; name=&#34;id&#34; value=&#34;&lt;?=$topic[&#39;id&#39;]?&gt;&#34; /&gt;
            &lt;p&gt;제목 : &lt;input type=&#34;text&#34; name=&#34;title&#34; value=&#34;&lt;?=htmlspecialchars($topic[&#39;title&#39;])?&gt;&#34;&gt;&lt;/p&gt;
            &lt;p&gt;본문 : &lt;textarea name=&#34;description&#34; id=&#34;&#34; cols=&#34;30&#34; rows=&#34;10&#34;&gt;&lt;?=htmlspecialchars($topic[&#39;description&#39;])?&gt;&lt;/textarea&gt;&lt;/p&gt;
            &lt;p&gt;&lt;input type=&#34;submit&#34; /&gt;&lt;/p&gt;
        &lt;/form&gt;
    &lt;/body&gt;
&lt;/html&gt;
```
{{&lt; /admonition &gt;}}

웹 접속 후 입력을 하게 되면
{{&lt; figure src=&#34;/images/practice/1-1.png&#34; title=&#34;입력#1&#34; &gt;}}

리스트에 추가가 된 것을 확인 할 수 있으며
{{&lt; figure src=&#34;/images/practice/1-2.png&#34; title=&#34;입력#2&#34; &gt;}}

아래와 같이 DB에 추가 된 것을 확인 할 수 있다.
{{&lt; figure src=&#34;/images/practice/1-3.png&#34; title=&#34;LIST&#34; &gt;}}

그리고 수정을 하게 되면
{{&lt; figure src=&#34;/images/practice/1-4.png&#34; title=&#34;수정#1&#34; &gt;}}
{{&lt; figure src=&#34;/images/practice/1-5.png&#34; title=&#34;수정#2&#34; &gt;}}

DB에서도 수정이 되는 것을 확인 할 수 있다.
{{&lt; figure src=&#34;/images/practice/1-6.png&#34; title=&#34;수정#3&#34; &gt;}}


[&lt;i class=&#34;fas fa-link&#34;&gt;&lt;/i&gt; 자료출처: 생활코딩](https://opentutorials.org/module/6/5155)


## 2. GOLANG

[&lt;i class=&#34;fas fa-link&#34;&gt;&lt;/i&gt; fmt link](https://pkg.go.dev/fmt)

### 2.1. Hello World

```go
package main

import &#34;fmt&#34;

func main() {
    fmt.println(&#34;Hello World&#34;)
}
```
{{&lt; figure src=&#34;/images/practice/2-1.png&#34; title=&#34;Hello World&#34; &gt;}}

### 2.2. Const

```go
package main

import &#34;fmt&#34;

func main() {
    var conferenceName = &#34;Go Conference&#34;
    const conferenceTickets = 50

    fmt.Println(&#34;Welcome to&#34;, conferenceName, &#34;booking application&#34;)
    fmt.Println(&#34;Get your tickets here to attend&#34;)

    conferenceTickets = 30
	fmt.Println(conferenceTickets)
}
```
const로 정의를 하면 아래처럼 값을 변경 할 수 없다.
{{&lt; figure src=&#34;/images/practice/2-2.png&#34; title=&#34;const&#34; &gt;}}

var로 변경을 하면 아래에서 30으로 변경이 가능하다.
{{&lt; figure src=&#34;/images/practice/2-3.png&#34; title=&#34;var 변경&#34; &gt;}}


### 2.3. printf

```go
package main

import &#34;fmt&#34;

func main() {
	var conferenceName = &#34;Go Conference&#34;
	const conferenceTickets = 50
	var remainingTickets = 50

	fmt.Printf(&#34;Welcome to %v booking application\n&#34;, conferenceName)
	fmt.Printf(&#34;We have total of %v tickets and %v are still available\n&#34;, conferenceTickets, remainingTickets)
	fmt.Println(&#34;Get your tickets here to attend&#34;)

}
```
{{&lt; figure src=&#34;/images/practice/2-4.png&#34; title=&#34;printf#1&#34; &gt;}}
{{&lt; figure src=&#34;/images/practice/2-5.png&#34; title=&#34;printf#2&#34; &gt;}}

### 2.4. Data Type

[&lt;i class=&#34;fas fa-link&#34;&gt;&lt;/i&gt; Golang DataType](https://www.tutorialspoint.com/go/go_data_types.htm)

설정한 DataType을 확인 할 수 있다.
fmt.Printf(&#34;Welcome to %T booking application\n&#34;, conferenceName)

var conferenceName = &#34;Go Confernece&#34; -&gt; conferenceName := &#34;Go Conference&#34; 로 하면 알아서 타입을 변경 해준다. 만약 숫자를 집어 넣으면 알아서 int로 변경을 해줌

```go
package main

import &#34;fmt&#34;

func main() {
	conferenceName := &#34;Go Conference&#34;
	const conferenceTickets = 50
	var remainingTickets = 50

	fmt.Printf(&#34;conferenceTickets is %T, remainingTickets is %T, conferencename is %T\n&#34;, conferenceTickets, remainingTickets, conferenceName)

	fmt.Printf(&#34;Welcome to %v booking application\n&#34;, conferenceName)
	fmt.Printf(&#34;We have total of %v tickets and %v are still available\n&#34;, conferenceTickets, remainingTickets)
	fmt.Println(&#34;Get your tickets here to attend&#34;)

	var userName string
	var userTickets int

	userName = &#34;TOM&#34;
	userTickets = 2
	fmt.Printf(&#34;User %v booked %v tickets.\n&#34;, userName, userTickets)
}


```
{{&lt; figure src=&#34;/images/practice/2-6.png&#34; title=&#34;datatype#1&#34; &gt;}}
{{&lt; figure src=&#34;/images/practice/2-7.png&#34; title=&#34;datatype#2&#34; &gt;}}

%T로 했을 경우 DataType을 확인 할 수 있다.
{{&lt; figure src=&#34;/images/practice/2-8.png&#34; title=&#34;datatype#3&#34; &gt;}}
{{&lt; figure src=&#34;/images/practice/2-9.png&#34; title=&#34;datatype#4&#34; &gt;}}


### 2.4. INPUT, 포인터를 사용해야한다.

&amp; &lt;- 포인터를 사용
fmt.Scan(&amp;useraName) 을하면 사용자가 입력을 할 수 있게 해준다.
포인터를 사용하지 않을 경우 저장된 메모리 값을 확인 할 수 있다.

```go
package main

import &#34;fmt&#34;

func main() {
	conferenceName := &#34;Go Conference&#34;
	const conferenceTickets = 50
	var remainingTickets uint = 50

	fmt.Printf(&#34;conferenceTickets is %T, remainingTickets is %T, conferencename is %T\n&#34;, conferenceTickets, remainingTickets, conferenceName)

	fmt.Printf(&#34;Welcome to %v booking application\n&#34;, conferenceName)
	fmt.Printf(&#34;We have total of %v tickets and %v are still available\n&#34;, conferenceTickets, remainingTickets)
	fmt.Println(&#34;Get your tickets here to attend&#34;)

	var firstName string
	var lastName string
	var email string
	var userTickets uint

	fmt.Println(&#34;Enter Your firstName: &#34;)
	fmt.Scan(&amp;firstName)                       // 이지점에서 사용자에게 물어봄

	fmt.Println(&#34;Enter Your lastName: &#34;)
	fmt.Scan(&amp;lastName)                        // 이지점에서 사용자에게 물어봄

	fmt.Println(&#34;Enter Your email: &#34;)
	fmt.Scan(&amp;email)                           // 이지점에서 사용자에게 물어봄

	fmt.Println(&#34;Enter number of tickets: &#34;)
	fmt.Scan(&amp;userTickets)                     // 이지점에서 사용자에게 물어봄

	remainingTickets = remainingTickets - userTickets

	fmt.Printf(&#34;Thank you %v %v for booking %v tickets. You will receive a confirmation email at %v\n&#34;, firstName, lastName, userTickets, email)
	fmt.Printf(&#34;%v tickets remaining for %v\n&#34;, remainingTickets, conferenceName)
}

```

{{&lt; figure src=&#34;/images/practice/2-10.png&#34; title=&#34;input&#34; &gt;}}


### 2.5. Array
배열의 경우 공간중간 값이 없어도 빈공간으로 인식을 하기 때문에 메모리를 그만큼 할당 하게 된다.

배열 2가지가 추가됨

var bookings [50]string

bookings[0] = firstName &#43; &#34; &#34; &#43; lastName

```go
package main

import &#34;fmt&#34;

func main() {
	conferenceName := &#34;Go Conference&#34;
	const conferenceTickets = 50
	var remainingTickets uint = 50
	var bookings [50]string

	fmt.Printf(&#34;conferenceTickets is %T, remainingTickets is %T, conferencename is %T\n&#34;, conferenceTickets, remainingTickets, conferenceName)

	fmt.Printf(&#34;Welcome to %v booking application\n&#34;, conferenceName)
	fmt.Printf(&#34;We have total of %v tickets and %v are still available\n&#34;, conferenceTickets, remainingTickets)
	fmt.Println(&#34;Get your tickets here to attend&#34;)

	var firstName string
	var lastName string
	var email string
	var userTickets uint

	fmt.Println(&#34;Enter Your firstName: &#34;)
	fmt.Scan(&amp;firstName)

	fmt.Println(&#34;Enter Your lastName: &#34;)
	fmt.Scan(&amp;lastName)

	fmt.Println(&#34;Enter Your email: &#34;)
	fmt.Scan(&amp;email)

	fmt.Println(&#34;Enter number of tickets: &#34;)
	fmt.Scan(&amp;userTickets)

	remainingTickets = remainingTickets - userTickets
	bookings[0] = firstName &#43; &#34; &#34; &#43; lastName

	fmt.Printf(&#34;The whole array: %v\n&#34;, bookings)
	fmt.Printf(&#34;The first value: %v\n&#34;, bookings[0])
	fmt.Printf(&#34;The first value: %T\n&#34;, bookings)
	fmt.Printf(&#34;The first value: %v\n&#34;, len(bookings))

	fmt.Printf(&#34;Thank you %v %v for booking %v tickets. You will receive a confirmation email at %v\n&#34;, firstName, lastName, userTickets, email)
	fmt.Printf(&#34;%v tickets remaining for %v\n&#34;, remainingTickets, conferenceName)
}

```

공간이 이미 할당이 되어 있는 것을 확인 할 수 있다.
{{&lt; figure src=&#34;/images/practice/2-11.png&#34; title=&#34;array&#34; &gt;}}

### 2.6. Slice

Slice구성 아래 2가지가 변경되고 하나 추가됨.
var bookings [50]string -&gt; bookings := []string{}

bookings[0] = firstName &#43; &#34; &#34; &#43; lastName -&gt;  bookings = append(bookings, firstName &#43; &#34; &#34; &#43; lastName)


fmt.Printf(&#34;These are all our booking: %v\n&#34;, bookings)

```go
package main

import &#34;fmt&#34;

func main() {
	conferenceName := &#34;Go Conference&#34;
	const conferenceTickets = 50
	var remainingTickets uint = 50
	bookings := []string{}

	fmt.Printf(&#34;conferenceTickets is %T, remainingTickets is %T, conferencename is %T\n&#34;, conferenceTickets, remainingTickets, conferenceName)

	fmt.Printf(&#34;Welcome to %v booking application\n&#34;, conferenceName)
	fmt.Printf(&#34;We have total of %v tickets and %v are still available\n&#34;, conferenceTickets, remainingTickets)
	fmt.Println(&#34;Get your tickets here to attend&#34;)

	var firstName string
	var lastName string
	var email string
	var userTickets uint

	fmt.Println(&#34;Enter Your firstName: &#34;)
	fmt.Scan(&amp;firstName)

	fmt.Println(&#34;Enter Your lastName: &#34;)
	fmt.Scan(&amp;lastName)

	fmt.Println(&#34;Enter Your email: &#34;)
	fmt.Scan(&amp;email)

	fmt.Println(&#34;Enter number of tickets: &#34;)
	fmt.Scan(&amp;userTickets)

	remainingTickets = remainingTickets - userTickets

	bookings = append(bookings, firstName&#43;&#34; &#34;&#43;lastName)

	fmt.Printf(&#34;The whole slice: %v\n&#34;, bookings)
	fmt.Printf(&#34;The first value: %v\n&#34;, bookings[0])
	fmt.Printf(&#34;The first type: %T\n&#34;, bookings)
	fmt.Printf(&#34;The first lgenth: %v\n&#34;, len(bookings))

	fmt.Printf(&#34;Thank you %v %v for booking %v tickets. You will receive a confirmation email at %v\n&#34;, firstName, lastName, userTickets, email)
	fmt.Printf(&#34;%v tickets remaining for %v\n&#34;, remainingTickets, conferenceName)

	fmt.Printf(&#34;These are all our booking: %v\n&#34;, bookings)
}

```

작성한 값만 들어가 있는 것을 확인 할 수 있다.
{{&lt; figure src=&#34;/images/practice/2-12.png&#34; title=&#34;slice&#34; &gt;}}

### 2.7 Loop &amp; If

```go
package main

import (
	&#34;fmt&#34;
	&#34;strings&#34;
)

func main() {
	conferenceName := &#34;Go Conference&#34;
	const conferenceTickets int = 50
	var remainingTickets uint = 50
	bookings := []string{}

	fmt.Printf(&#34;conferenceTickets is %T, remainingTickets is %T, conferencename is %T\n&#34;, conferenceTickets, remainingTickets, conferenceName)

	fmt.Printf(&#34;Welcome to %v booking application\n&#34;, conferenceName)
	fmt.Printf(&#34;We have total of %v tickets and %v are still available\n&#34;, conferenceTickets, remainingTickets)
	fmt.Println(&#34;Get your tickets here to attend&#34;)

	for {
		var firstName string
		var lastName string
		var email string
		var userTickets uint

		fmt.Println(&#34;Enter Your firstName: &#34;)
		fmt.Scan(&amp;firstName)

		fmt.Println(&#34;Enter Your lastName: &#34;)
		fmt.Scan(&amp;lastName)

		fmt.Println(&#34;Enter Your email: &#34;)
		fmt.Scan(&amp;email)

		fmt.Println(&#34;Enter number of tickets: &#34;)
		fmt.Scan(&amp;userTickets)

		isValidName := len(firstName) &gt;= 2 &amp;&amp; len(lastName) &gt;= 2
		isValidEmail := strings.Contains(email, &#34;@&#34;)
		isValidTicketNumber := userTickets &gt; 0 &amp;&amp; userTickets &lt;= remainingTickets

		if isValidName &amp;&amp; isValidEmail &amp;&amp; isValidTicketNumber {
			remainingTickets = remainingTickets - userTickets
			bookings = append(bookings, firstName&#43;&#34; &#34;&#43;lastName)

			fmt.Printf(&#34;Thank you %v %v for booking %v tickets. You will receive a confirmation email at %v\n&#34;, firstName, lastName, userTickets, email)
			fmt.Printf(&#34;%v tickets remaining for %v\n&#34;, remainingTickets, conferenceName)

			firstNames := []string{}
			for _, booking := range bookings {
				var names = strings.Fields(booking)
				firstNames = append(firstNames, names[0])
			}
			fmt.Printf(&#34;These first names of bookings are: %v\n&#34;, firstNames)

			if remainingTickets == 0 {
				fmt.Println(&#34;Our conference is booked out. Come back next year.&#34;)
				break
			}
		} else {
			if !isValidName {
				fmt.Println(&#34;first name or last name you entered is too short&#34;)
			}
			if !isValidEmail {
				fmt.Println(&#34;email address you entered doesn&#39;t contain @ sign&#34;)
			}
			if !isValidTicketNumber {
				fmt.Println(&#34;number of tickets you entered is invalid&#34;)
			}
		}
	}
}

```

### 2.8. function


```go
package main

import (
	&#34;fmt&#34;
	&#34;strings&#34;
)

func main() {
	conferenceName := &#34;Go Conference&#34;
	const conferenceTickets int = 50
	var remainingTickets uint = 50
	bookings := []string{}

	greetUsers(conferenceName, conferenceTickets, remainingTickets)

	for {
		var firstName string
		var lastName string
		var email string
		var userTickets uint

		fmt.Println(&#34;Enter Your firstName: &#34;)
		fmt.Scan(&amp;firstName)

		fmt.Println(&#34;Enter Your lastName: &#34;)
		fmt.Scan(&amp;lastName)

		fmt.Println(&#34;Enter Your email: &#34;)
		fmt.Scan(&amp;email)

		fmt.Println(&#34;Enter number of tickets: &#34;)
		fmt.Scan(&amp;userTickets)

		isValidName := len(firstName) &gt;= 2 &amp;&amp; len(lastName) &gt;= 2
		isValidEmail := strings.Contains(email, &#34;@&#34;)
		isValidTicketNumber := userTickets &gt; 0 &amp;&amp; userTickets &lt;= remainingTickets

		if isValidName &amp;&amp; isValidEmail &amp;&amp; isValidTicketNumber {
			remainingTickets = remainingTickets - userTickets
			bookings = append(bookings, firstName&#43;&#34; &#34;&#43;lastName)

			fmt.Printf(&#34;Thank you %v %v for booking %v tickets. You will receive a confirmation email at %v\n&#34;, firstName, lastName, userTickets, email)
			fmt.Printf(&#34;%v tickets remaining for %v\n&#34;, remainingTickets, conferenceName)

			printFirstNames(bookings)

			if remainingTickets == 0 {
				fmt.Println(&#34;Our conference is booked out. Come back next year.&#34;)
				break
			}
		} else {
			if !isValidName {
				fmt.Println(&#34;first name or last name you entered is too short&#34;)
			}
			if !isValidEmail {
				fmt.Println(&#34;email address you entered doesn&#39;t contain @ sign&#34;)
			}
			if !isValidTicketNumber {
				fmt.Println(&#34;number of tickets you entered is invalid&#34;)
			}
		}
	}
}

func greetUsers(confName string, confTickets int, remainingTickets uint) {
	fmt.Printf(&#34;Welcome to %v booking application\n&#34;, confName)
	fmt.Printf(&#34;We have total of %v tickets and %v are still available\n&#34;, confTickets, remainingTickets)
	fmt.Println(&#34;Get your tickets here to attend&#34;)
}

func printFirstNames(bookings []string) {
	firstNames := []string{}
	for _, booking := range bookings {
		var names = strings.Fields(booking)
		firstNames = append(firstNames, names[0])
	}
	fmt.Printf(&#34;These first names of bookings are: %v\n&#34;, firstNames)
}

```

### 2.9. return func

```go
package main

import (
	&#34;fmt&#34;
	&#34;strings&#34;
)

const conferenceTickets int = 50

var conferenceName string = &#34;Go Conference&#34;
var remainingTickets uint = 50
var bookings = []string{}

func main() {

	greetUsers()

	for {
		firstName, lastName, email, userTickets := getUserInput()
		isValidName, isValidEmail, isValidTicketNumber := validateUserInput(firstName, lastName, email, userTickets)

		if isValidName &amp;&amp; isValidEmail &amp;&amp; isValidTicketNumber {

			bookTicket(userTickets, firstName, lastName, email)

			firstNames := getFirstNames()
			fmt.Printf(&#34;The first names of bookins are: %v\n&#34;, firstNames)

			if remainingTickets == 0 {
				fmt.Println(&#34;Our conference is booked out. Come back next year.&#34;)
				break
			}
		} else {
			if !isValidName {
				fmt.Println(&#34;first name or last name you entered is too short&#34;)
			}
			if !isValidEmail {
				fmt.Println(&#34;email address you entered doesn&#39;t contain @ sign&#34;)
			}
			if !isValidTicketNumber {
				fmt.Println(&#34;number of tickets you entered is invalid&#34;)
			}
		}
	}
}

func greetUsers() {
	fmt.Printf(&#34;Welcome to %v booking application\n&#34;, conferenceName)
	fmt.Printf(&#34;We have total of %v tickets and %v are still available\n&#34;, conferenceTickets, remainingTickets)
	fmt.Println(&#34;Get your tickets here to attend&#34;)
}

func getFirstNames() []string {
	firstNames := []string{}
	for _, booking := range bookings {
		var names = strings.Fields(booking)
		firstNames = append(firstNames, names[0])
	}
	return firstNames
}

func validateUserInput(firstName string, lastName string, email string, userTickets uint) (bool, bool, bool) {
	isValidName := len(firstName) &gt;= 2 &amp;&amp; len(lastName) &gt;= 2
	isValidEmail := strings.Contains(email, &#34;@&#34;)
	isValidTicketNumber := userTickets &gt; 0 &amp;&amp; userTickets &lt;= remainingTickets

	return isValidName, isValidEmail, isValidTicketNumber
}

func getUserInput() (string, string, string, uint) {
	var firstName string
	var lastName string
	var email string
	var userTickets uint

	fmt.Println(&#34;Enter Your firstName: &#34;)
	fmt.Scan(&amp;firstName)

	fmt.Println(&#34;Enter Your lastName: &#34;)
	fmt.Scan(&amp;lastName)

	fmt.Println(&#34;Enter Your email: &#34;)
	fmt.Scan(&amp;email)

	fmt.Println(&#34;Enter number of tickets: &#34;)
	fmt.Scan(&amp;userTickets)

	return firstName, lastName, email, userTickets
}

func bookTicket(userTickets uint, firstName string, lastName string, email string) {
	remainingTickets = remainingTickets - userTickets
	bookings = append(bookings, firstName&#43;&#34; &#34;&#43;lastName)

	fmt.Printf(&#34;Thank you %v %v for booking %v tickets. You will receive a confirmation email at %v\n&#34;, firstName, lastName, userTickets, email)
	fmt.Printf(&#34;%v tickets remaining for %v\n&#34;, remainingTickets, conferenceName)

}


```

### 2.10. package

helper.go 파일 생성

```shell
package main

import &#34;strings&#34;

func validateUserInput(firstName string, lastName string, email string, userTickets uint) (bool, bool, bool) {
	isValidName := len(firstName) &gt;= 2 &amp;&amp; len(lastName) &gt;= 2
	isValidEmail := strings.Contains(email, &#34;@&#34;)
	isValidTicketNumber := userTickets &gt; 0 &amp;&amp; userTickets &lt;= remainingTickets

	return isValidName, isValidEmail, isValidTicketNumber
}

```

main.go 
```go
package main

import (
	&#34;fmt&#34;
	&#34;strings&#34;
)

const conferenceTickets int = 50

var conferenceName string = &#34;Go Conference&#34;
var remainingTickets uint = 50
var bookings = []string{}

func main() {

	greetUsers()

	for {
		firstName, lastName, email, userTickets := getUserInput()
		isValidName, isValidEmail, isValidTicketNumber := validateUserInput(firstName, lastName, email, userTickets)

		if isValidName &amp;&amp; isValidEmail &amp;&amp; isValidTicketNumber {

			bookTicket(userTickets, firstName, lastName, email)

			firstNames := getFirstNames()
			fmt.Printf(&#34;The first names of bookins are: %v\n&#34;, firstNames)

			if remainingTickets == 0 {
				fmt.Println(&#34;Our conference is booked out. Come back next year.&#34;)
				break
			}
		} else {
			if !isValidName {
				fmt.Println(&#34;first name or last name you entered is too short&#34;)
			}
			if !isValidEmail {
				fmt.Println(&#34;email address you entered doesn&#39;t contain @ sign&#34;)
			}
			if !isValidTicketNumber {
				fmt.Println(&#34;number of tickets you entered is invalid&#34;)
			}
		}
	}
}

func greetUsers() {
	fmt.Printf(&#34;Welcome to %v booking application\n&#34;, conferenceName)
	fmt.Printf(&#34;We have total of %v tickets and %v are still available\n&#34;, conferenceTickets, remainingTickets)
	fmt.Println(&#34;Get your tickets here to attend&#34;)
}

func getFirstNames() []string {
	firstNames := []string{}
	for _, booking := range bookings {
		var names = strings.Fields(booking)
		firstNames = append(firstNames, names[0])
	}
	return firstNames
}

func getUserInput() (string, string, string, uint) {
	var firstName string
	var lastName string
	var email string
	var userTickets uint

	fmt.Println(&#34;Enter Your firstName: &#34;)
	fmt.Scan(&amp;firstName)

	fmt.Println(&#34;Enter Your lastName: &#34;)
	fmt.Scan(&amp;lastName)

	fmt.Println(&#34;Enter Your email: &#34;)
	fmt.Scan(&amp;email)

	fmt.Println(&#34;Enter number of tickets: &#34;)
	fmt.Scan(&amp;userTickets)

	return firstName, lastName, email, userTickets
}

func bookTicket(userTickets uint, firstName string, lastName string, email string) {
	remainingTickets = remainingTickets - userTickets
	bookings = append(bookings, firstName&#43;&#34; &#34;&#43;lastName)

	fmt.Printf(&#34;Thank you %v %v for booking %v tickets. You will receive a confirmation email at %v\n&#34;, firstName, lastName, userTickets, email)
	fmt.Printf(&#34;%v tickets remaining for %v\n&#34;, remainingTickets, conferenceName)

}

```

### 2.11. multi package

helper.go
```go
package helper

import &#34;strings&#34;

func ValidateUserInput(firstName string, lastName string, email string, userTickets uint, remainingTickets uint) (bool, bool, bool) {
	isValidName := len(firstName) &gt;= 2 &amp;&amp; len(lastName) &gt;= 2
	isValidEmail := strings.Contains(email, &#34;@&#34;)
	isValidTicketNumber := userTickets &gt; 0 &amp;&amp; userTickets &lt;= remainingTickets

	return isValidName, isValidEmail, isValidTicketNumber
}


```
main.go
```go
package main

import (
	&#34;GOLANG/helper&#34;
	&#34;fmt&#34;
	&#34;strings&#34;
)

const conferenceTickets int = 50

var conferenceName string = &#34;Go Conference&#34;
var remainingTickets uint = 50
var bookings = []string{}

func main() {

	greetUsers()

	for {
		firstName, lastName, email, userTickets := getUserInput()
		isValidName, isValidEmail, isValidTicketNumber := helper.ValidateUserInput(firstName, lastName, email, userTickets, remainingTickets)

		if isValidName &amp;&amp; isValidEmail &amp;&amp; isValidTicketNumber {

			bookTicket(userTickets, firstName, lastName, email)

			firstNames := getFirstNames()
			fmt.Printf(&#34;The first names of bookins are: %v\n&#34;, firstNames)

			if remainingTickets == 0 {
				fmt.Println(&#34;Our conference is booked out. Come back next year.&#34;)
				break
			}
		} else {
			if !isValidName {
				fmt.Println(&#34;first name or last name you entered is too short&#34;)
			}
			if !isValidEmail {
				fmt.Println(&#34;email address you entered doesn&#39;t contain @ sign&#34;)
			}
			if !isValidTicketNumber {
				fmt.Println(&#34;number of tickets you entered is invalid&#34;)
			}
		}
	}
}

func greetUsers() {
	fmt.Printf(&#34;Welcome to %v booking application\n&#34;, conferenceName)
	fmt.Printf(&#34;We have total of %v tickets and %v are still available\n&#34;, conferenceTickets, remainingTickets)
	fmt.Println(&#34;Get your tickets here to attend&#34;)
}

func getFirstNames() []string {
	firstNames := []string{}
	for _, booking := range bookings {
		var names = strings.Fields(booking)
		firstNames = append(firstNames, names[0])
	}
	return firstNames
}

func getUserInput() (string, string, string, uint) {
	var firstName string
	var lastName string
	var email string
	var userTickets uint

	fmt.Println(&#34;Enter Your firstName: &#34;)
	fmt.Scan(&amp;firstName)

	fmt.Println(&#34;Enter Your lastName: &#34;)
	fmt.Scan(&amp;lastName)

	fmt.Println(&#34;Enter Your email: &#34;)
	fmt.Scan(&amp;email)

	fmt.Println(&#34;Enter number of tickets: &#34;)
	fmt.Scan(&amp;userTickets)

	return firstName, lastName, email, userTickets
}

func bookTicket(userTickets uint, firstName string, lastName string, email string) {
	remainingTickets = remainingTickets - userTickets
	bookings = append(bookings, firstName&#43;&#34; &#34;&#43;lastName)

	fmt.Printf(&#34;Thank you %v %v for booking %v tickets. You will receive a confirmation email at %v\n&#34;, firstName, lastName, userTickets, email)
	fmt.Printf(&#34;%v tickets remaining for %v\n&#34;, remainingTickets, conferenceName)

}

```

{{&lt; figure src=&#34;/images/practice/2-13.png&#34; title=&#34;multi pacakge&#34; &gt;}}

### 2.12. MAPS

```go
package main

import (
	&#34;fmt&#34;
	&#34;strconv&#34;
)

const conferenceTickets int = 50

var conferenceName string = &#34;Go Conference&#34;
var remainingTickets uint = 50
var bookings = make([]map[string]string, 0)

func main() {

	greetUsers()

	for {
		firstName, lastName, email, userTickets := getUserInput()
		isValidName, isValidEmail, isValidTicketNumber := validateUserInput(firstName, lastName, email, userTickets)

		if isValidName &amp;&amp; isValidEmail &amp;&amp; isValidTicketNumber {

			bookTicket(userTickets, firstName, lastName, email)

			firstNames := getFirstNames()
			fmt.Printf(&#34;The first names of bookins are: %v\n&#34;, firstNames)

			if remainingTickets == 0 {
				fmt.Println(&#34;Our conference is booked out. Come back next year.&#34;)
				break
			}
		} else {
			if !isValidName {
				fmt.Println(&#34;first name or last name you entered is too short&#34;)
			}
			if !isValidEmail {
				fmt.Println(&#34;email address you entered doesn&#39;t contain @ sign&#34;)
			}
			if !isValidTicketNumber {
				fmt.Println(&#34;number of tickets you entered is invalid&#34;)
			}
		}
	}
}

func greetUsers() {
	fmt.Printf(&#34;Welcome to %v booking application\n&#34;, conferenceName)
	fmt.Printf(&#34;We have total of %v tickets and %v are still available\n&#34;, conferenceTickets, remainingTickets)
	fmt.Println(&#34;Get your tickets here to attend&#34;)
}

func getFirstNames() []string {
	firstNames := []string{}
	for _, booking := range bookings {
		firstNames = append(firstNames, booking[&#34;firtName&#34;])
	}
	return firstNames
}

func getUserInput() (string, string, string, uint) {
	var firstName string
	var lastName string
	var email string
	var userTickets uint

	fmt.Println(&#34;Enter Your firstName: &#34;)
	fmt.Scan(&amp;firstName)

	fmt.Println(&#34;Enter Your lastName: &#34;)
	fmt.Scan(&amp;lastName)

	fmt.Println(&#34;Enter Your email: &#34;)
	fmt.Scan(&amp;email)

	fmt.Println(&#34;Enter number of tickets: &#34;)
	fmt.Scan(&amp;userTickets)

	return firstName, lastName, email, userTickets
}

func bookTicket(userTickets uint, firstName string, lastName string, email string) {
	remainingTickets = remainingTickets - userTickets

	var userData = make(map[string]string)
	userData[&#34;firstName&#34;] = firstName
	userData[&#34;lastName&#34;] = lastName
	userData[&#34;email&#34;] = email
	userData[&#34;numberOfTickets&#34;] = strconv.FormatUint(uint64(userTickets), 10)

	bookings = append(bookings, userData)

	fmt.Printf(&#34;List of bookings is %v\n&#34;, bookings)

	fmt.Printf(&#34;Thank you %v %v for booking %v tickets. You will receive a confirmation email at %v\n&#34;, firstName, lastName, userTickets, email)
	fmt.Printf(&#34;%v tickets remaining for %v\n&#34;, remainingTickets, conferenceName)

}

```

{{&lt; figure src=&#34;/images/practice/2-14.png&#34; title=&#34;maps&#34; &gt;}}

### 2.13. struct
```go
package main

import (
	&#34;fmt&#34;
)

const conferenceTickets int = 50

var conferenceName string = &#34;Go Conference&#34;
var remainingTickets uint = 50
var bookings = make([]UserData, 0)

type UserData struct {
	firstName       string
	lastName        string
	email           string
	numberOfTickets uint
}

func main() {

	greetUsers()

	for {
		firstName, lastName, email, userTickets := getUserInput()
		isValidName, isValidEmail, isValidTicketNumber := validateUserInput(firstName, lastName, email, userTickets)

		if isValidName &amp;&amp; isValidEmail &amp;&amp; isValidTicketNumber {

			bookTicket(userTickets, firstName, lastName, email)

			firstNames := getFirstNames()
			fmt.Printf(&#34;The first names of bookins are: %v\n&#34;, firstNames)

			if remainingTickets == 0 {
				fmt.Println(&#34;Our conference is booked out. Come back next year.&#34;)
				break
			}
		} else {
			if !isValidName {
				fmt.Println(&#34;first name or last name you entered is too short&#34;)
			}
			if !isValidEmail {
				fmt.Println(&#34;email address you entered doesn&#39;t contain @ sign&#34;)
			}
			if !isValidTicketNumber {
				fmt.Println(&#34;number of tickets you entered is invalid&#34;)
			}
		}
	}
}

func greetUsers() {
	fmt.Printf(&#34;Welcome to %v booking application\n&#34;, conferenceName)
	fmt.Printf(&#34;We have total of %v tickets and %v are still available\n&#34;, conferenceTickets, remainingTickets)
	fmt.Println(&#34;Get your tickets here to attend&#34;)
}

func getFirstNames() []string {
	firstNames := []string{}
	for _, booking := range bookings {
		firstNames = append(firstNames, booking.firstName)
	}
	return firstNames
}

func getUserInput() (string, string, string, uint) {
	var firstName string
	var lastName string
	var email string
	var userTickets uint

	fmt.Println(&#34;Enter Your firstName: &#34;)
	fmt.Scan(&amp;firstName)

	fmt.Println(&#34;Enter Your lastName: &#34;)
	fmt.Scan(&amp;lastName)

	fmt.Println(&#34;Enter Your email: &#34;)
	fmt.Scan(&amp;email)

	fmt.Println(&#34;Enter number of tickets: &#34;)
	fmt.Scan(&amp;userTickets)

	return firstName, lastName, email, userTickets
}

func bookTicket(userTickets uint, firstName string, lastName string, email string) {
	remainingTickets = remainingTickets - userTickets

	var userData = UserData{
		firstName:       firstName,
		lastName:        lastName,
		email:           email,
		numberOfTickets: userTickets,
	}

	bookings = append(bookings, userData)

	fmt.Printf(&#34;List of bookings is %v\n&#34;, bookings)

	fmt.Printf(&#34;Thank you %v %v for booking %v tickets. You will receive a confirmation email at %v\n&#34;, firstName, lastName, userTickets, email)
	fmt.Printf(&#34;%v tickets remaining for %v\n&#34;, remainingTickets, conferenceName)

}

```

{{&lt; figure src=&#34;/images/practice/2-15.png&#34; title=&#34;struct&#34; &gt;}}

### 2.14. long processing task

메일을 보내는 10초간 기다리게 구성

```go
package main

import (
	&#34;fmt&#34;
	&#34;time&#34;
)

const conferenceTickets int = 50

var conferenceName string = &#34;Go Conference&#34;
var remainingTickets uint = 50
var bookings = make([]UserData, 0)

type UserData struct {
	firstName       string
	lastName        string
	email           string
	numberOfTickets uint
}

func main() {

	greetUsers()

	for {
		firstName, lastName, email, userTickets := getUserInput()
		isValidName, isValidEmail, isValidTicketNumber := validateUserInput(firstName, lastName, email, userTickets)

		if isValidName &amp;&amp; isValidEmail &amp;&amp; isValidTicketNumber {

			bookTicket(userTickets, firstName, lastName, email)
			sendTicket(userTickets, firstName, lastName, email)

			firstNames := getFirstNames()
			fmt.Printf(&#34;The first names of bookins are: %v\n&#34;, firstNames)

			if remainingTickets == 0 {
				fmt.Println(&#34;Our conference is booked out. Come back next year.&#34;)
				break
			}
		} else {
			if !isValidName {
				fmt.Println(&#34;first name or last name you entered is too short&#34;)
			}
			if !isValidEmail {
				fmt.Println(&#34;email address you entered doesn&#39;t contain @ sign&#34;)
			}
			if !isValidTicketNumber {
				fmt.Println(&#34;number of tickets you entered is invalid&#34;)
			}
		}
	}
}

func greetUsers() {
	fmt.Printf(&#34;Welcome to %v booking application\n&#34;, conferenceName)
	fmt.Printf(&#34;We have total of %v tickets and %v are still available\n&#34;, conferenceTickets, remainingTickets)
	fmt.Println(&#34;Get your tickets here to attend&#34;)
}

func getFirstNames() []string {
	firstNames := []string{}
	for _, booking := range bookings {
		firstNames = append(firstNames, booking.firstName)
	}
	return firstNames
}

func getUserInput() (string, string, string, uint) {
	var firstName string
	var lastName string
	var email string
	var userTickets uint

	fmt.Println(&#34;Enter Your firstName: &#34;)
	fmt.Scan(&amp;firstName)

	fmt.Println(&#34;Enter Your lastName: &#34;)
	fmt.Scan(&amp;lastName)

	fmt.Println(&#34;Enter Your email: &#34;)
	fmt.Scan(&amp;email)

	fmt.Println(&#34;Enter number of tickets: &#34;)
	fmt.Scan(&amp;userTickets)

	return firstName, lastName, email, userTickets
}

func bookTicket(userTickets uint, firstName string, lastName string, email string) {
	remainingTickets = remainingTickets - userTickets

	var userData = UserData{
		firstName:       firstName,
		lastName:        lastName,
		email:           email,
		numberOfTickets: userTickets,
	}

	bookings = append(bookings, userData)

	fmt.Printf(&#34;List of bookings is %v\n&#34;, bookings)

	fmt.Printf(&#34;Thank you %v %v for booking %v tickets. You will receive a confirmation email at %v\n&#34;, firstName, lastName, userTickets, email)
	fmt.Printf(&#34;%v tickets remaining for %v\n&#34;, remainingTickets, conferenceName)

}

func sendTicket(userTickets uint, firstName string, lastName string, email string) {
	time.Sleep(10 * time.Second)
	var ticket = fmt.Sprintf(&#34;%v tickets for %v %v&#34;, userTickets, firstName, lastName)
	fmt.Println(&#34;#########################&#34;)
	fmt.Printf(&#34;Sending ticket: \n %v to email address %v\n&#34;, ticket, email)
	fmt.Println(&#34;#########################&#34;)
}

```

{{&lt; figure src=&#34;/images/practice/2-16.png&#34; title=&#34;long processing&#34; &gt;}}

### 2.15. 비동기

메일을 기다리지 않고 보내면서 메일은 별도로 보내지게 구성 한다.

```go
package main

import (
	&#34;fmt&#34;
	&#34;time&#34;
)

const conferenceTickets int = 50

var conferenceName string = &#34;Go Conference&#34;
var remainingTickets uint = 50
var bookings = make([]UserData, 0)

type UserData struct {
	firstName       string
	lastName        string
	email           string
	numberOfTickets uint
}

func main() {

	greetUsers()

	for {
		firstName, lastName, email, userTickets := getUserInput()
		isValidName, isValidEmail, isValidTicketNumber := validateUserInput(firstName, lastName, email, userTickets)

		if isValidName &amp;&amp; isValidEmail &amp;&amp; isValidTicketNumber {

			bookTicket(userTickets, firstName, lastName, email)
            
            // go라는 것을 넣어주면 된다.
			go sendTicket(userTickets, firstName, lastName, email)

			firstNames := getFirstNames()
			fmt.Printf(&#34;The first names of bookins are: %v\n&#34;, firstNames)

			if remainingTickets == 0 {
				fmt.Println(&#34;Our conference is booked out. Come back next year.&#34;)
				break
			}
		} else {
			if !isValidName {
				fmt.Println(&#34;first name or last name you entered is too short&#34;)
			}
			if !isValidEmail {
				fmt.Println(&#34;email address you entered doesn&#39;t contain @ sign&#34;)
			}
			if !isValidTicketNumber {
				fmt.Println(&#34;number of tickets you entered is invalid&#34;)
			}
		}
	}
}

func greetUsers() {
	fmt.Printf(&#34;Welcome to %v booking application\n&#34;, conferenceName)
	fmt.Printf(&#34;We have total of %v tickets and %v are still available\n&#34;, conferenceTickets, remainingTickets)
	fmt.Println(&#34;Get your tickets here to attend&#34;)
}

func getFirstNames() []string {
	firstNames := []string{}
	for _, booking := range bookings {
		firstNames = append(firstNames, booking.firstName)
	}
	return firstNames
}

func getUserInput() (string, string, string, uint) {
	var firstName string
	var lastName string
	var email string
	var userTickets uint

	fmt.Println(&#34;Enter Your firstName: &#34;)
	fmt.Scan(&amp;firstName)

	fmt.Println(&#34;Enter Your lastName: &#34;)
	fmt.Scan(&amp;lastName)

	fmt.Println(&#34;Enter Your email: &#34;)
	fmt.Scan(&amp;email)

	fmt.Println(&#34;Enter number of tickets: &#34;)
	fmt.Scan(&amp;userTickets)

	return firstName, lastName, email, userTickets
}

func bookTicket(userTickets uint, firstName string, lastName string, email string) {
	remainingTickets = remainingTickets - userTickets

	var userData = UserData{
		firstName:       firstName,
		lastName:        lastName,
		email:           email,
		numberOfTickets: userTickets,
	}

	bookings = append(bookings, userData)

	fmt.Printf(&#34;List of bookings is %v\n&#34;, bookings)

	fmt.Printf(&#34;Thank you %v %v for booking %v tickets. You will receive a confirmation email at %v\n&#34;, firstName, lastName, userTickets, email)
	fmt.Printf(&#34;%v tickets remaining for %v\n&#34;, remainingTickets, conferenceName)

}

func sendTicket(userTickets uint, firstName string, lastName string, email string) {
	time.Sleep(10 * time.Second)
	var ticket = fmt.Sprintf(&#34;%v tickets for %v %v&#34;, userTickets, firstName, lastName)
	fmt.Println(&#34;#########################&#34;)
	fmt.Printf(&#34;Sending ticket: \n %v to email address %v\n&#34;, ticket, email)
	fmt.Println(&#34;#########################&#34;)
}

```

### 1.16. 동기

sync 함수를 사용한다.
```go
package main

import (
	&#34;fmt&#34;
	&#34;sync&#34;
	&#34;time&#34;
)

const conferenceTickets int = 50

var conferenceName string = &#34;Go Conference&#34;
var remainingTickets uint = 50
var bookings = make([]UserData, 0)

type UserData struct {
	firstName       string
	lastName        string
	email           string
	numberOfTickets uint
}

var wg = sync.WaitGroup{}

func main() {

	greetUsers()

	//for {
	firstName, lastName, email, userTickets := getUserInput()
	isValidName, isValidEmail, isValidTicketNumber := validateUserInput(firstName, lastName, email, userTickets)

	if isValidName &amp;&amp; isValidEmail &amp;&amp; isValidTicketNumber {

		bookTicket(userTickets, firstName, lastName, email)

		wg.Add(1)
		go sendTicket(userTickets, firstName, lastName, email)

		firstNames := getFirstNames()
		fmt.Printf(&#34;The first names of bookins are: %v\n&#34;, firstNames)

		if remainingTickets == 0 {
			fmt.Println(&#34;Our conference is booked out. Come back next year.&#34;)
			//break
		}
	} else {
		if !isValidName {
			fmt.Println(&#34;first name or last name you entered is too short&#34;)
		}
		if !isValidEmail {
			fmt.Println(&#34;email address you entered doesn&#39;t contain @ sign&#34;)
		}
		if !isValidTicketNumber {
			fmt.Println(&#34;number of tickets you entered is invalid&#34;)
		}
	}
	wg.Wait()
	//}
}

func greetUsers() {
	fmt.Printf(&#34;Welcome to %v booking application\n&#34;, conferenceName)
	fmt.Printf(&#34;We have total of %v tickets and %v are still available\n&#34;, conferenceTickets, remainingTickets)
	fmt.Println(&#34;Get your tickets here to attend&#34;)
}

func getFirstNames() []string {
	firstNames := []string{}
	for _, booking := range bookings {
		firstNames = append(firstNames, booking.firstName)
	}
	return firstNames
}

func getUserInput() (string, string, string, uint) {
	var firstName string
	var lastName string
	var email string
	var userTickets uint

	fmt.Println(&#34;Enter Your firstName: &#34;)
	fmt.Scan(&amp;firstName)

	fmt.Println(&#34;Enter Your lastName: &#34;)
	fmt.Scan(&amp;lastName)

	fmt.Println(&#34;Enter Your email: &#34;)
	fmt.Scan(&amp;email)

	fmt.Println(&#34;Enter number of tickets: &#34;)
	fmt.Scan(&amp;userTickets)

	return firstName, lastName, email, userTickets
}

func bookTicket(userTickets uint, firstName string, lastName string, email string) {
	remainingTickets = remainingTickets - userTickets

	var userData = UserData{
		firstName:       firstName,
		lastName:        lastName,
		email:           email,
		numberOfTickets: userTickets,
	}

	bookings = append(bookings, userData)

	fmt.Printf(&#34;List of bookings is %v\n&#34;, bookings)

	fmt.Printf(&#34;Thank you %v %v for booking %v tickets. You will receive a confirmation email at %v\n&#34;, firstName, lastName, userTickets, email)
	fmt.Printf(&#34;%v tickets remaining for %v\n&#34;, remainingTickets, conferenceName)

}

func sendTicket(userTickets uint, firstName string, lastName string, email string) {
	time.Sleep(10 * time.Second)
	var ticket = fmt.Sprintf(&#34;%v tickets for %v %v&#34;, userTickets, firstName, lastName)
	fmt.Println(&#34;#########################&#34;)
	fmt.Printf(&#34;Sending ticket: \n %v to email address %v\n&#34;, ticket, email)
	fmt.Println(&#34;#########################&#34;)
	wg.Done()
}

```

[&lt;i class=&#34;fas fa-link&#34;&gt;&lt;/i&gt; 참고동영상: TechWorld with Nana](https://youtu.be/yyUHQIec83I)

---

> Author: Dokyung  
> URL: https://huntedhappy.github.io/ko/pratics/  

