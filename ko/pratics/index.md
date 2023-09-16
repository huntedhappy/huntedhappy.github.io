# The Documentation Practics


본 문서는 코딩 따라하기 테스트 페이지, 제가 다른 문서를 참조해서 따라해보는 페이지 입니다.


## 1. NGINX + PHP + MYSQL 연동

환경
* UBUNTU: VERSION="20.04.3 LTS (Focal Fossa)"
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

{{< admonition example "mysql 사전 작업" >}}
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
{{< /admonition >}}

{{< admonition example "PHP 구성" >}}
input.php
```php
<!DOCTYPE html>
<html>
    <head>
        <meta charset="utf-8"/>
    </head>
    <body>
        <form action="./process.php?mode=insert" method="POST">
            <p>제목 : <input type="text" name="title"></p>
            <p>본문 : <textarea name="description" id="" cols="30" rows="10"></textarea></p>
            <p><input type="submit" /></p>
        </form>
    </body>
</html>
```
process.php
```php
<?php
$dbh = new PDO('mysql:host=localhost;dbname=opentutorials', 'root', '111111', array(PDO::MYSQL_ATTR_INIT_COMMAND => "SET NAMES utf8"));
switch($_GET['mode']){
    case 'insert':
        $stmt = $dbh->prepare("INSERT INTO topic (title, description, created) VALUES (:title, :description, now())");
        $stmt->bindParam(':title',$title);
        $stmt->bindParam(':description',$description);
 
        $title = $_POST['title'];
        $description = $_POST['description'];
        $stmt->execute();
        header("Location: list.php"); 
        break;
    case 'delete':
        $stmt = $dbh->prepare('DELETE FROM topic WHERE id = :id');
        $stmt->bindParam(':id', $id);
 
        $id = $_POST['id'];
        $stmt->execute();
        header("Location: list.php"); 
        break;
    case 'modify':
        $stmt = $dbh->prepare('UPDATE topic SET title = :title, description = :description WHERE id = :id');
        $stmt->bindParam(':title', $title);
        $stmt->bindParam(':description', $description);
        $stmt->bindParam(':id', $id);
 
        $title = $_POST['title'];
        $description = $_POST['description'];
        $id = $_POST['id'];
        $stmt->execute();
        header("Location: list.php?id={$_POST['id']}");
        break;
}
?>
```
list.php
```php
<?php
$dbh = new PDO('mysql:host=localhost;dbname=opentutorials', 'root', '111111');
$stmt = $dbh->prepare('SELECT * FROM topic');
$stmt->execute();
$list = $stmt->fetchAll();
if(!empty($_GET['id'])) {
    $stmt = $dbh->prepare('SELECT * FROM topic WHERE id = :id');
    $stmt->bindParam(':id', $id, PDO::PARAM_INT);
    $id = $_GET['id'];
    $stmt->execute();
    $topic = $stmt->fetch();
}
?>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="utf-8" />
        <style type="text/css">
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
        </style>
    </head>
   
    <body id="body">
        <div>
            <nav>
                <ul>
                    <?php
                    foreach($list as $row) {
                        echo "<li><a href=\"?id={$row['id']}\">".htmlspecialchars($row['title'])."</a></li>";                        }
                    ?>
                </ul>
                <ul>
                    <li><a href="input.php">추가</a></li>
                </ul>
            </nav>
            <article>
                <?php
                if(!empty($topic)){
                ?>
                <h2><?=htmlspecialchars($topic['title'])?></h2>
                <div class="description">
                    <?=htmlspecialchars($topic['description'])?>
                </div>
                <div>
                    <a href="modify.php?id=<?=$topic['id']?>">수정</a>
                    <form method="POST" action="process.php?mode=delete">
                        <input type="hidden" name="id" value="<?=$topic['id']?>" />
                        <input type="submit" value="삭제" />
                    </form>
                </div>
                <?php
                }
                ?>
            </article>
        </div>
    </body>
</html>
```

modify.php
```php
<?php
$dbh = new PDO('mysql:host=localhost;dbname=opentutorials', 'root', '111111');
$stmt = $dbh->prepare('SELECT * FROM topic WHERE id = :id');
$stmt->bindParam(':id', $id, PDO::PARAM_INT);
$id = $_GET['id'];
$stmt->execute();
$topic = $stmt->fetch();
?>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="utf-8"/>
    </head>   
    <body>
        <form action="./process.php?mode=modify" method="POST">
            <input type="hidden" name="id" value="<?=$topic['id']?>" />
            <p>제목 : <input type="text" name="title" value="<?=htmlspecialchars($topic['title'])?>"></p>
            <p>본문 : <textarea name="description" id="" cols="30" rows="10"><?=htmlspecialchars($topic['description'])?></textarea></p>
            <p><input type="submit" /></p>
        </form>
    </body>
</html>
```
{{< /admonition >}}

웹 접속 후 입력을 하게 되면
{{< figure src="/images/practice/1-1.png" title="입력#1" >}}

리스트에 추가가 된 것을 확인 할 수 있으며
{{< figure src="/images/practice/1-2.png" title="입력#2" >}}

아래와 같이 DB에 추가 된 것을 확인 할 수 있다.
{{< figure src="/images/practice/1-3.png" title="LIST" >}}

그리고 수정을 하게 되면
{{< figure src="/images/practice/1-4.png" title="수정#1" >}}
{{< figure src="/images/practice/1-5.png" title="수정#2" >}}

DB에서도 수정이 되는 것을 확인 할 수 있다.
{{< figure src="/images/practice/1-6.png" title="수정#3" >}}


[<i class="fas fa-link"></i> 자료출처: 생활코딩](https://opentutorials.org/module/6/5155)


## 2. GOLANG

[<i class="fas fa-link"></i> fmt link](https://pkg.go.dev/fmt)

### 2.1. Hello World

```go
package main

import "fmt"

func main() {
    fmt.println("Hello World")
}
```
{{< figure src="/images/practice/2-1.png" title="Hello World" >}}

### 2.2. Const

```go
package main

import "fmt"

func main() {
    var conferenceName = "Go Conference"
    const conferenceTickets = 50

    fmt.Println("Welcome to", conferenceName, "booking application")
    fmt.Println("Get your tickets here to attend")

    conferenceTickets = 30
	fmt.Println(conferenceTickets)
}
```
const로 정의를 하면 아래처럼 값을 변경 할 수 없다.
{{< figure src="/images/practice/2-2.png" title="const" >}}

var로 변경을 하면 아래에서 30으로 변경이 가능하다.
{{< figure src="/images/practice/2-3.png" title="var 변경" >}}


### 2.3. printf

```go
package main

import "fmt"

func main() {
	var conferenceName = "Go Conference"
	const conferenceTickets = 50
	var remainingTickets = 50

	fmt.Printf("Welcome to %v booking application\n", conferenceName)
	fmt.Printf("We have total of %v tickets and %v are still available\n", conferenceTickets, remainingTickets)
	fmt.Println("Get your tickets here to attend")

}
```
{{< figure src="/images/practice/2-4.png" title="printf#1" >}}
{{< figure src="/images/practice/2-5.png" title="printf#2" >}}

### 2.4. Data Type

[<i class="fas fa-link"></i> Golang DataType](https://www.tutorialspoint.com/go/go_data_types.htm)

설정한 DataType을 확인 할 수 있다.
fmt.Printf("Welcome to %T booking application\n", conferenceName)

var conferenceName = "Go Confernece" -> conferenceName := "Go Conference" 로 하면 알아서 타입을 변경 해준다. 만약 숫자를 집어 넣으면 알아서 int로 변경을 해줌

```go
package main

import "fmt"

func main() {
	conferenceName := "Go Conference"
	const conferenceTickets = 50
	var remainingTickets = 50

	fmt.Printf("conferenceTickets is %T, remainingTickets is %T, conferencename is %T\n", conferenceTickets, remainingTickets, conferenceName)

	fmt.Printf("Welcome to %v booking application\n", conferenceName)
	fmt.Printf("We have total of %v tickets and %v are still available\n", conferenceTickets, remainingTickets)
	fmt.Println("Get your tickets here to attend")

	var userName string
	var userTickets int

	userName = "TOM"
	userTickets = 2
	fmt.Printf("User %v booked %v tickets.\n", userName, userTickets)
}


```
{{< figure src="/images/practice/2-6.png" title="datatype#1" >}}
{{< figure src="/images/practice/2-7.png" title="datatype#2" >}}

%T로 했을 경우 DataType을 확인 할 수 있다.
{{< figure src="/images/practice/2-8.png" title="datatype#3" >}}
{{< figure src="/images/practice/2-9.png" title="datatype#4" >}}


### 2.4. INPUT, 포인터를 사용해야한다.

& <- 포인터를 사용
fmt.Scan(&useraName) 을하면 사용자가 입력을 할 수 있게 해준다.
포인터를 사용하지 않을 경우 저장된 메모리 값을 확인 할 수 있다.

```go
package main

import "fmt"

func main() {
	conferenceName := "Go Conference"
	const conferenceTickets = 50
	var remainingTickets uint = 50

	fmt.Printf("conferenceTickets is %T, remainingTickets is %T, conferencename is %T\n", conferenceTickets, remainingTickets, conferenceName)

	fmt.Printf("Welcome to %v booking application\n", conferenceName)
	fmt.Printf("We have total of %v tickets and %v are still available\n", conferenceTickets, remainingTickets)
	fmt.Println("Get your tickets here to attend")

	var firstName string
	var lastName string
	var email string
	var userTickets uint

	fmt.Println("Enter Your firstName: ")
	fmt.Scan(&firstName)                       // 이지점에서 사용자에게 물어봄

	fmt.Println("Enter Your lastName: ")
	fmt.Scan(&lastName)                        // 이지점에서 사용자에게 물어봄

	fmt.Println("Enter Your email: ")
	fmt.Scan(&email)                           // 이지점에서 사용자에게 물어봄

	fmt.Println("Enter number of tickets: ")
	fmt.Scan(&userTickets)                     // 이지점에서 사용자에게 물어봄

	remainingTickets = remainingTickets - userTickets

	fmt.Printf("Thank you %v %v for booking %v tickets. You will receive a confirmation email at %v\n", firstName, lastName, userTickets, email)
	fmt.Printf("%v tickets remaining for %v\n", remainingTickets, conferenceName)
}

```

{{< figure src="/images/practice/2-10.png" title="input" >}}


### 2.5. Array
배열의 경우 공간중간 값이 없어도 빈공간으로 인식을 하기 때문에 메모리를 그만큼 할당 하게 된다.

배열 2가지가 추가됨

var bookings [50]string

bookings[0] = firstName + " " + lastName

```go
package main

import "fmt"

func main() {
	conferenceName := "Go Conference"
	const conferenceTickets = 50
	var remainingTickets uint = 50
	var bookings [50]string

	fmt.Printf("conferenceTickets is %T, remainingTickets is %T, conferencename is %T\n", conferenceTickets, remainingTickets, conferenceName)

	fmt.Printf("Welcome to %v booking application\n", conferenceName)
	fmt.Printf("We have total of %v tickets and %v are still available\n", conferenceTickets, remainingTickets)
	fmt.Println("Get your tickets here to attend")

	var firstName string
	var lastName string
	var email string
	var userTickets uint

	fmt.Println("Enter Your firstName: ")
	fmt.Scan(&firstName)

	fmt.Println("Enter Your lastName: ")
	fmt.Scan(&lastName)

	fmt.Println("Enter Your email: ")
	fmt.Scan(&email)

	fmt.Println("Enter number of tickets: ")
	fmt.Scan(&userTickets)

	remainingTickets = remainingTickets - userTickets
	bookings[0] = firstName + " " + lastName

	fmt.Printf("The whole array: %v\n", bookings)
	fmt.Printf("The first value: %v\n", bookings[0])
	fmt.Printf("The first value: %T\n", bookings)
	fmt.Printf("The first value: %v\n", len(bookings))

	fmt.Printf("Thank you %v %v for booking %v tickets. You will receive a confirmation email at %v\n", firstName, lastName, userTickets, email)
	fmt.Printf("%v tickets remaining for %v\n", remainingTickets, conferenceName)
}

```

공간이 이미 할당이 되어 있는 것을 확인 할 수 있다.
{{< figure src="/images/practice/2-11.png" title="array" >}}

### 2.6. Slice

Slice구성 아래 2가지가 변경되고 하나 추가됨.
var bookings [50]string -> bookings := []string{}

bookings[0] = firstName + " " + lastName ->  bookings = append(bookings, firstName + " " + lastName)


fmt.Printf("These are all our booking: %v\n", bookings)

```go
package main

import "fmt"

func main() {
	conferenceName := "Go Conference"
	const conferenceTickets = 50
	var remainingTickets uint = 50
	bookings := []string{}

	fmt.Printf("conferenceTickets is %T, remainingTickets is %T, conferencename is %T\n", conferenceTickets, remainingTickets, conferenceName)

	fmt.Printf("Welcome to %v booking application\n", conferenceName)
	fmt.Printf("We have total of %v tickets and %v are still available\n", conferenceTickets, remainingTickets)
	fmt.Println("Get your tickets here to attend")

	var firstName string
	var lastName string
	var email string
	var userTickets uint

	fmt.Println("Enter Your firstName: ")
	fmt.Scan(&firstName)

	fmt.Println("Enter Your lastName: ")
	fmt.Scan(&lastName)

	fmt.Println("Enter Your email: ")
	fmt.Scan(&email)

	fmt.Println("Enter number of tickets: ")
	fmt.Scan(&userTickets)

	remainingTickets = remainingTickets - userTickets

	bookings = append(bookings, firstName+" "+lastName)

	fmt.Printf("The whole slice: %v\n", bookings)
	fmt.Printf("The first value: %v\n", bookings[0])
	fmt.Printf("The first type: %T\n", bookings)
	fmt.Printf("The first lgenth: %v\n", len(bookings))

	fmt.Printf("Thank you %v %v for booking %v tickets. You will receive a confirmation email at %v\n", firstName, lastName, userTickets, email)
	fmt.Printf("%v tickets remaining for %v\n", remainingTickets, conferenceName)

	fmt.Printf("These are all our booking: %v\n", bookings)
}

```

작성한 값만 들어가 있는 것을 확인 할 수 있다.
{{< figure src="/images/practice/2-12.png" title="slice" >}}

### 2.7 Loop & If

```go
package main

import (
	"fmt"
	"strings"
)

func main() {
	conferenceName := "Go Conference"
	const conferenceTickets int = 50
	var remainingTickets uint = 50
	bookings := []string{}

	fmt.Printf("conferenceTickets is %T, remainingTickets is %T, conferencename is %T\n", conferenceTickets, remainingTickets, conferenceName)

	fmt.Printf("Welcome to %v booking application\n", conferenceName)
	fmt.Printf("We have total of %v tickets and %v are still available\n", conferenceTickets, remainingTickets)
	fmt.Println("Get your tickets here to attend")

	for {
		var firstName string
		var lastName string
		var email string
		var userTickets uint

		fmt.Println("Enter Your firstName: ")
		fmt.Scan(&firstName)

		fmt.Println("Enter Your lastName: ")
		fmt.Scan(&lastName)

		fmt.Println("Enter Your email: ")
		fmt.Scan(&email)

		fmt.Println("Enter number of tickets: ")
		fmt.Scan(&userTickets)

		isValidName := len(firstName) >= 2 && len(lastName) >= 2
		isValidEmail := strings.Contains(email, "@")
		isValidTicketNumber := userTickets > 0 && userTickets <= remainingTickets

		if isValidName && isValidEmail && isValidTicketNumber {
			remainingTickets = remainingTickets - userTickets
			bookings = append(bookings, firstName+" "+lastName)

			fmt.Printf("Thank you %v %v for booking %v tickets. You will receive a confirmation email at %v\n", firstName, lastName, userTickets, email)
			fmt.Printf("%v tickets remaining for %v\n", remainingTickets, conferenceName)

			firstNames := []string{}
			for _, booking := range bookings {
				var names = strings.Fields(booking)
				firstNames = append(firstNames, names[0])
			}
			fmt.Printf("These first names of bookings are: %v\n", firstNames)

			if remainingTickets == 0 {
				fmt.Println("Our conference is booked out. Come back next year.")
				break
			}
		} else {
			if !isValidName {
				fmt.Println("first name or last name you entered is too short")
			}
			if !isValidEmail {
				fmt.Println("email address you entered doesn't contain @ sign")
			}
			if !isValidTicketNumber {
				fmt.Println("number of tickets you entered is invalid")
			}
		}
	}
}

```

### 2.8. function


```go
package main

import (
	"fmt"
	"strings"
)

func main() {
	conferenceName := "Go Conference"
	const conferenceTickets int = 50
	var remainingTickets uint = 50
	bookings := []string{}

	greetUsers(conferenceName, conferenceTickets, remainingTickets)

	for {
		var firstName string
		var lastName string
		var email string
		var userTickets uint

		fmt.Println("Enter Your firstName: ")
		fmt.Scan(&firstName)

		fmt.Println("Enter Your lastName: ")
		fmt.Scan(&lastName)

		fmt.Println("Enter Your email: ")
		fmt.Scan(&email)

		fmt.Println("Enter number of tickets: ")
		fmt.Scan(&userTickets)

		isValidName := len(firstName) >= 2 && len(lastName) >= 2
		isValidEmail := strings.Contains(email, "@")
		isValidTicketNumber := userTickets > 0 && userTickets <= remainingTickets

		if isValidName && isValidEmail && isValidTicketNumber {
			remainingTickets = remainingTickets - userTickets
			bookings = append(bookings, firstName+" "+lastName)

			fmt.Printf("Thank you %v %v for booking %v tickets. You will receive a confirmation email at %v\n", firstName, lastName, userTickets, email)
			fmt.Printf("%v tickets remaining for %v\n", remainingTickets, conferenceName)

			printFirstNames(bookings)

			if remainingTickets == 0 {
				fmt.Println("Our conference is booked out. Come back next year.")
				break
			}
		} else {
			if !isValidName {
				fmt.Println("first name or last name you entered is too short")
			}
			if !isValidEmail {
				fmt.Println("email address you entered doesn't contain @ sign")
			}
			if !isValidTicketNumber {
				fmt.Println("number of tickets you entered is invalid")
			}
		}
	}
}

func greetUsers(confName string, confTickets int, remainingTickets uint) {
	fmt.Printf("Welcome to %v booking application\n", confName)
	fmt.Printf("We have total of %v tickets and %v are still available\n", confTickets, remainingTickets)
	fmt.Println("Get your tickets here to attend")
}

func printFirstNames(bookings []string) {
	firstNames := []string{}
	for _, booking := range bookings {
		var names = strings.Fields(booking)
		firstNames = append(firstNames, names[0])
	}
	fmt.Printf("These first names of bookings are: %v\n", firstNames)
}

```

### 2.9. return func

```go
package main

import (
	"fmt"
	"strings"
)

const conferenceTickets int = 50

var conferenceName string = "Go Conference"
var remainingTickets uint = 50
var bookings = []string{}

func main() {

	greetUsers()

	for {
		firstName, lastName, email, userTickets := getUserInput()
		isValidName, isValidEmail, isValidTicketNumber := validateUserInput(firstName, lastName, email, userTickets)

		if isValidName && isValidEmail && isValidTicketNumber {

			bookTicket(userTickets, firstName, lastName, email)

			firstNames := getFirstNames()
			fmt.Printf("The first names of bookins are: %v\n", firstNames)

			if remainingTickets == 0 {
				fmt.Println("Our conference is booked out. Come back next year.")
				break
			}
		} else {
			if !isValidName {
				fmt.Println("first name or last name you entered is too short")
			}
			if !isValidEmail {
				fmt.Println("email address you entered doesn't contain @ sign")
			}
			if !isValidTicketNumber {
				fmt.Println("number of tickets you entered is invalid")
			}
		}
	}
}

func greetUsers() {
	fmt.Printf("Welcome to %v booking application\n", conferenceName)
	fmt.Printf("We have total of %v tickets and %v are still available\n", conferenceTickets, remainingTickets)
	fmt.Println("Get your tickets here to attend")
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
	isValidName := len(firstName) >= 2 && len(lastName) >= 2
	isValidEmail := strings.Contains(email, "@")
	isValidTicketNumber := userTickets > 0 && userTickets <= remainingTickets

	return isValidName, isValidEmail, isValidTicketNumber
}

func getUserInput() (string, string, string, uint) {
	var firstName string
	var lastName string
	var email string
	var userTickets uint

	fmt.Println("Enter Your firstName: ")
	fmt.Scan(&firstName)

	fmt.Println("Enter Your lastName: ")
	fmt.Scan(&lastName)

	fmt.Println("Enter Your email: ")
	fmt.Scan(&email)

	fmt.Println("Enter number of tickets: ")
	fmt.Scan(&userTickets)

	return firstName, lastName, email, userTickets
}

func bookTicket(userTickets uint, firstName string, lastName string, email string) {
	remainingTickets = remainingTickets - userTickets
	bookings = append(bookings, firstName+" "+lastName)

	fmt.Printf("Thank you %v %v for booking %v tickets. You will receive a confirmation email at %v\n", firstName, lastName, userTickets, email)
	fmt.Printf("%v tickets remaining for %v\n", remainingTickets, conferenceName)

}


```

### 2.10. package

helper.go 파일 생성

```shell
package main

import "strings"

func validateUserInput(firstName string, lastName string, email string, userTickets uint) (bool, bool, bool) {
	isValidName := len(firstName) >= 2 && len(lastName) >= 2
	isValidEmail := strings.Contains(email, "@")
	isValidTicketNumber := userTickets > 0 && userTickets <= remainingTickets

	return isValidName, isValidEmail, isValidTicketNumber
}

```

main.go 
```go
package main

import (
	"fmt"
	"strings"
)

const conferenceTickets int = 50

var conferenceName string = "Go Conference"
var remainingTickets uint = 50
var bookings = []string{}

func main() {

	greetUsers()

	for {
		firstName, lastName, email, userTickets := getUserInput()
		isValidName, isValidEmail, isValidTicketNumber := validateUserInput(firstName, lastName, email, userTickets)

		if isValidName && isValidEmail && isValidTicketNumber {

			bookTicket(userTickets, firstName, lastName, email)

			firstNames := getFirstNames()
			fmt.Printf("The first names of bookins are: %v\n", firstNames)

			if remainingTickets == 0 {
				fmt.Println("Our conference is booked out. Come back next year.")
				break
			}
		} else {
			if !isValidName {
				fmt.Println("first name or last name you entered is too short")
			}
			if !isValidEmail {
				fmt.Println("email address you entered doesn't contain @ sign")
			}
			if !isValidTicketNumber {
				fmt.Println("number of tickets you entered is invalid")
			}
		}
	}
}

func greetUsers() {
	fmt.Printf("Welcome to %v booking application\n", conferenceName)
	fmt.Printf("We have total of %v tickets and %v are still available\n", conferenceTickets, remainingTickets)
	fmt.Println("Get your tickets here to attend")
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

	fmt.Println("Enter Your firstName: ")
	fmt.Scan(&firstName)

	fmt.Println("Enter Your lastName: ")
	fmt.Scan(&lastName)

	fmt.Println("Enter Your email: ")
	fmt.Scan(&email)

	fmt.Println("Enter number of tickets: ")
	fmt.Scan(&userTickets)

	return firstName, lastName, email, userTickets
}

func bookTicket(userTickets uint, firstName string, lastName string, email string) {
	remainingTickets = remainingTickets - userTickets
	bookings = append(bookings, firstName+" "+lastName)

	fmt.Printf("Thank you %v %v for booking %v tickets. You will receive a confirmation email at %v\n", firstName, lastName, userTickets, email)
	fmt.Printf("%v tickets remaining for %v\n", remainingTickets, conferenceName)

}

```

### 2.11. multi package

helper.go
```go
package helper

import "strings"

func ValidateUserInput(firstName string, lastName string, email string, userTickets uint, remainingTickets uint) (bool, bool, bool) {
	isValidName := len(firstName) >= 2 && len(lastName) >= 2
	isValidEmail := strings.Contains(email, "@")
	isValidTicketNumber := userTickets > 0 && userTickets <= remainingTickets

	return isValidName, isValidEmail, isValidTicketNumber
}


```
main.go
```go
package main

import (
	"GOLANG/helper"
	"fmt"
	"strings"
)

const conferenceTickets int = 50

var conferenceName string = "Go Conference"
var remainingTickets uint = 50
var bookings = []string{}

func main() {

	greetUsers()

	for {
		firstName, lastName, email, userTickets := getUserInput()
		isValidName, isValidEmail, isValidTicketNumber := helper.ValidateUserInput(firstName, lastName, email, userTickets, remainingTickets)

		if isValidName && isValidEmail && isValidTicketNumber {

			bookTicket(userTickets, firstName, lastName, email)

			firstNames := getFirstNames()
			fmt.Printf("The first names of bookins are: %v\n", firstNames)

			if remainingTickets == 0 {
				fmt.Println("Our conference is booked out. Come back next year.")
				break
			}
		} else {
			if !isValidName {
				fmt.Println("first name or last name you entered is too short")
			}
			if !isValidEmail {
				fmt.Println("email address you entered doesn't contain @ sign")
			}
			if !isValidTicketNumber {
				fmt.Println("number of tickets you entered is invalid")
			}
		}
	}
}

func greetUsers() {
	fmt.Printf("Welcome to %v booking application\n", conferenceName)
	fmt.Printf("We have total of %v tickets and %v are still available\n", conferenceTickets, remainingTickets)
	fmt.Println("Get your tickets here to attend")
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

	fmt.Println("Enter Your firstName: ")
	fmt.Scan(&firstName)

	fmt.Println("Enter Your lastName: ")
	fmt.Scan(&lastName)

	fmt.Println("Enter Your email: ")
	fmt.Scan(&email)

	fmt.Println("Enter number of tickets: ")
	fmt.Scan(&userTickets)

	return firstName, lastName, email, userTickets
}

func bookTicket(userTickets uint, firstName string, lastName string, email string) {
	remainingTickets = remainingTickets - userTickets
	bookings = append(bookings, firstName+" "+lastName)

	fmt.Printf("Thank you %v %v for booking %v tickets. You will receive a confirmation email at %v\n", firstName, lastName, userTickets, email)
	fmt.Printf("%v tickets remaining for %v\n", remainingTickets, conferenceName)

}

```

{{< figure src="/images/practice/2-13.png" title="multi pacakge" >}}

### 2.12. MAPS

```go
package main

import (
	"fmt"
	"strconv"
)

const conferenceTickets int = 50

var conferenceName string = "Go Conference"
var remainingTickets uint = 50
var bookings = make([]map[string]string, 0)

func main() {

	greetUsers()

	for {
		firstName, lastName, email, userTickets := getUserInput()
		isValidName, isValidEmail, isValidTicketNumber := validateUserInput(firstName, lastName, email, userTickets)

		if isValidName && isValidEmail && isValidTicketNumber {

			bookTicket(userTickets, firstName, lastName, email)

			firstNames := getFirstNames()
			fmt.Printf("The first names of bookins are: %v\n", firstNames)

			if remainingTickets == 0 {
				fmt.Println("Our conference is booked out. Come back next year.")
				break
			}
		} else {
			if !isValidName {
				fmt.Println("first name or last name you entered is too short")
			}
			if !isValidEmail {
				fmt.Println("email address you entered doesn't contain @ sign")
			}
			if !isValidTicketNumber {
				fmt.Println("number of tickets you entered is invalid")
			}
		}
	}
}

func greetUsers() {
	fmt.Printf("Welcome to %v booking application\n", conferenceName)
	fmt.Printf("We have total of %v tickets and %v are still available\n", conferenceTickets, remainingTickets)
	fmt.Println("Get your tickets here to attend")
}

func getFirstNames() []string {
	firstNames := []string{}
	for _, booking := range bookings {
		firstNames = append(firstNames, booking["firtName"])
	}
	return firstNames
}

func getUserInput() (string, string, string, uint) {
	var firstName string
	var lastName string
	var email string
	var userTickets uint

	fmt.Println("Enter Your firstName: ")
	fmt.Scan(&firstName)

	fmt.Println("Enter Your lastName: ")
	fmt.Scan(&lastName)

	fmt.Println("Enter Your email: ")
	fmt.Scan(&email)

	fmt.Println("Enter number of tickets: ")
	fmt.Scan(&userTickets)

	return firstName, lastName, email, userTickets
}

func bookTicket(userTickets uint, firstName string, lastName string, email string) {
	remainingTickets = remainingTickets - userTickets

	var userData = make(map[string]string)
	userData["firstName"] = firstName
	userData["lastName"] = lastName
	userData["email"] = email
	userData["numberOfTickets"] = strconv.FormatUint(uint64(userTickets), 10)

	bookings = append(bookings, userData)

	fmt.Printf("List of bookings is %v\n", bookings)

	fmt.Printf("Thank you %v %v for booking %v tickets. You will receive a confirmation email at %v\n", firstName, lastName, userTickets, email)
	fmt.Printf("%v tickets remaining for %v\n", remainingTickets, conferenceName)

}

```

{{< figure src="/images/practice/2-14.png" title="maps" >}}

### 2.13. struct
```go
package main

import (
	"fmt"
)

const conferenceTickets int = 50

var conferenceName string = "Go Conference"
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

		if isValidName && isValidEmail && isValidTicketNumber {

			bookTicket(userTickets, firstName, lastName, email)

			firstNames := getFirstNames()
			fmt.Printf("The first names of bookins are: %v\n", firstNames)

			if remainingTickets == 0 {
				fmt.Println("Our conference is booked out. Come back next year.")
				break
			}
		} else {
			if !isValidName {
				fmt.Println("first name or last name you entered is too short")
			}
			if !isValidEmail {
				fmt.Println("email address you entered doesn't contain @ sign")
			}
			if !isValidTicketNumber {
				fmt.Println("number of tickets you entered is invalid")
			}
		}
	}
}

func greetUsers() {
	fmt.Printf("Welcome to %v booking application\n", conferenceName)
	fmt.Printf("We have total of %v tickets and %v are still available\n", conferenceTickets, remainingTickets)
	fmt.Println("Get your tickets here to attend")
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

	fmt.Println("Enter Your firstName: ")
	fmt.Scan(&firstName)

	fmt.Println("Enter Your lastName: ")
	fmt.Scan(&lastName)

	fmt.Println("Enter Your email: ")
	fmt.Scan(&email)

	fmt.Println("Enter number of tickets: ")
	fmt.Scan(&userTickets)

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

	fmt.Printf("List of bookings is %v\n", bookings)

	fmt.Printf("Thank you %v %v for booking %v tickets. You will receive a confirmation email at %v\n", firstName, lastName, userTickets, email)
	fmt.Printf("%v tickets remaining for %v\n", remainingTickets, conferenceName)

}

```

{{< figure src="/images/practice/2-15.png" title="struct" >}}

### 2.14. long processing task

메일을 보내는 10초간 기다리게 구성

```go
package main

import (
	"fmt"
	"time"
)

const conferenceTickets int = 50

var conferenceName string = "Go Conference"
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

		if isValidName && isValidEmail && isValidTicketNumber {

			bookTicket(userTickets, firstName, lastName, email)
			sendTicket(userTickets, firstName, lastName, email)

			firstNames := getFirstNames()
			fmt.Printf("The first names of bookins are: %v\n", firstNames)

			if remainingTickets == 0 {
				fmt.Println("Our conference is booked out. Come back next year.")
				break
			}
		} else {
			if !isValidName {
				fmt.Println("first name or last name you entered is too short")
			}
			if !isValidEmail {
				fmt.Println("email address you entered doesn't contain @ sign")
			}
			if !isValidTicketNumber {
				fmt.Println("number of tickets you entered is invalid")
			}
		}
	}
}

func greetUsers() {
	fmt.Printf("Welcome to %v booking application\n", conferenceName)
	fmt.Printf("We have total of %v tickets and %v are still available\n", conferenceTickets, remainingTickets)
	fmt.Println("Get your tickets here to attend")
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

	fmt.Println("Enter Your firstName: ")
	fmt.Scan(&firstName)

	fmt.Println("Enter Your lastName: ")
	fmt.Scan(&lastName)

	fmt.Println("Enter Your email: ")
	fmt.Scan(&email)

	fmt.Println("Enter number of tickets: ")
	fmt.Scan(&userTickets)

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

	fmt.Printf("List of bookings is %v\n", bookings)

	fmt.Printf("Thank you %v %v for booking %v tickets. You will receive a confirmation email at %v\n", firstName, lastName, userTickets, email)
	fmt.Printf("%v tickets remaining for %v\n", remainingTickets, conferenceName)

}

func sendTicket(userTickets uint, firstName string, lastName string, email string) {
	time.Sleep(10 * time.Second)
	var ticket = fmt.Sprintf("%v tickets for %v %v", userTickets, firstName, lastName)
	fmt.Println("#########################")
	fmt.Printf("Sending ticket: \n %v to email address %v\n", ticket, email)
	fmt.Println("#########################")
}

```

{{< figure src="/images/practice/2-16.png" title="long processing" >}}

### 2.15. 비동기

메일을 기다리지 않고 보내면서 메일은 별도로 보내지게 구성 한다.

```go
package main

import (
	"fmt"
	"time"
)

const conferenceTickets int = 50

var conferenceName string = "Go Conference"
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

		if isValidName && isValidEmail && isValidTicketNumber {

			bookTicket(userTickets, firstName, lastName, email)
            
            // go라는 것을 넣어주면 된다.
			go sendTicket(userTickets, firstName, lastName, email)

			firstNames := getFirstNames()
			fmt.Printf("The first names of bookins are: %v\n", firstNames)

			if remainingTickets == 0 {
				fmt.Println("Our conference is booked out. Come back next year.")
				break
			}
		} else {
			if !isValidName {
				fmt.Println("first name or last name you entered is too short")
			}
			if !isValidEmail {
				fmt.Println("email address you entered doesn't contain @ sign")
			}
			if !isValidTicketNumber {
				fmt.Println("number of tickets you entered is invalid")
			}
		}
	}
}

func greetUsers() {
	fmt.Printf("Welcome to %v booking application\n", conferenceName)
	fmt.Printf("We have total of %v tickets and %v are still available\n", conferenceTickets, remainingTickets)
	fmt.Println("Get your tickets here to attend")
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

	fmt.Println("Enter Your firstName: ")
	fmt.Scan(&firstName)

	fmt.Println("Enter Your lastName: ")
	fmt.Scan(&lastName)

	fmt.Println("Enter Your email: ")
	fmt.Scan(&email)

	fmt.Println("Enter number of tickets: ")
	fmt.Scan(&userTickets)

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

	fmt.Printf("List of bookings is %v\n", bookings)

	fmt.Printf("Thank you %v %v for booking %v tickets. You will receive a confirmation email at %v\n", firstName, lastName, userTickets, email)
	fmt.Printf("%v tickets remaining for %v\n", remainingTickets, conferenceName)

}

func sendTicket(userTickets uint, firstName string, lastName string, email string) {
	time.Sleep(10 * time.Second)
	var ticket = fmt.Sprintf("%v tickets for %v %v", userTickets, firstName, lastName)
	fmt.Println("#########################")
	fmt.Printf("Sending ticket: \n %v to email address %v\n", ticket, email)
	fmt.Println("#########################")
}

```

### 1.16. 동기

sync 함수를 사용한다.
```go
package main

import (
	"fmt"
	"sync"
	"time"
)

const conferenceTickets int = 50

var conferenceName string = "Go Conference"
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

	if isValidName && isValidEmail && isValidTicketNumber {

		bookTicket(userTickets, firstName, lastName, email)

		wg.Add(1)
		go sendTicket(userTickets, firstName, lastName, email)

		firstNames := getFirstNames()
		fmt.Printf("The first names of bookins are: %v\n", firstNames)

		if remainingTickets == 0 {
			fmt.Println("Our conference is booked out. Come back next year.")
			//break
		}
	} else {
		if !isValidName {
			fmt.Println("first name or last name you entered is too short")
		}
		if !isValidEmail {
			fmt.Println("email address you entered doesn't contain @ sign")
		}
		if !isValidTicketNumber {
			fmt.Println("number of tickets you entered is invalid")
		}
	}
	wg.Wait()
	//}
}

func greetUsers() {
	fmt.Printf("Welcome to %v booking application\n", conferenceName)
	fmt.Printf("We have total of %v tickets and %v are still available\n", conferenceTickets, remainingTickets)
	fmt.Println("Get your tickets here to attend")
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

	fmt.Println("Enter Your firstName: ")
	fmt.Scan(&firstName)

	fmt.Println("Enter Your lastName: ")
	fmt.Scan(&lastName)

	fmt.Println("Enter Your email: ")
	fmt.Scan(&email)

	fmt.Println("Enter number of tickets: ")
	fmt.Scan(&userTickets)

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

	fmt.Printf("List of bookings is %v\n", bookings)

	fmt.Printf("Thank you %v %v for booking %v tickets. You will receive a confirmation email at %v\n", firstName, lastName, userTickets, email)
	fmt.Printf("%v tickets remaining for %v\n", remainingTickets, conferenceName)

}

func sendTicket(userTickets uint, firstName string, lastName string, email string) {
	time.Sleep(10 * time.Second)
	var ticket = fmt.Sprintf("%v tickets for %v %v", userTickets, firstName, lastName)
	fmt.Println("#########################")
	fmt.Printf("Sending ticket: \n %v to email address %v\n", ticket, email)
	fmt.Println("#########################")
	wg.Done()
}

```

[<i class="fas fa-link"></i> 참고동영상: TechWorld with Nana](https://youtu.be/yyUHQIec83I)
