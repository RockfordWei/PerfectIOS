# PerfectIOS: Server-Side Swift for iOS
<p align="center">
    <a href="http://perfect.org/get-involved.html" target="_blank">
        <img src="http://perfect.org/assets/github/perfect_github_2_0_0.jpg" alt="Get Involed with Perfect!" width="854" />
    </a>
</p>

<p align="center">
    <a href="https://developer.apple.com/swift/" target="_blank">
        <img src="https://img.shields.io/badge/Swift-5.6-orange.svg?style=flat" alt="Swift 5.6">
    </a>
    <a href="https://developer.apple.com/swift/" target="_blank">
        <img src="https://img.shields.io/badge/Platforms-OS%20X%20%7C%20Linux%20-lightgray.svg?style=flat" alt="Platforms macOS | Linux">
    </a>
    <a href="http://perfect.org/licensing.html" target="_blank">
        <img src="https://img.shields.io/badge/License-Apache-lightgrey.svg?style=flat" alt="License Apache">
    </a>
</p>

## Perfect: Server-Side Swift

Perfect is a complete and powerful toolbox, framework, and application server for Linux, iOS, and macOS (OS X). It provides everything a Swift engineer needs for developing lightweight, maintainable, and scalable apps and other REST services entirely in the Swift programming language for both client-facing and server-side applications.

Perfect includes a suite of tools that will enhance your productivity as you use only one programming language to build your apps: Swift. The global development community’s most dynamic and popular server-side toolbox and framework available today, Perfect is the backbone for many live web applications and apps available on iTunes.

This guide is designed for developers at all levels of experience to get Perfect up and running quickly.

## PerfectIOS

PerfectIOS is a lightweight httpd/web server designed for iOS unit test.

First, add PerfectIOS to your project:

```swift
    .package(url: "https://github.com/RockfordWei/PerfectIOS", .exact("5.4.0"))
```

Then, a http server will be available in the unit test:

```swift
import PerfectHTTP
import PerfectHTTPServer

import XCTest
@testable import PerfectIOSExample

final class PerfectIOSExampleTests: XCTestCase {

    var httpServer: HTTPServer.LaunchContext?
    let greetings = "Hello, world!"
    let port = 8181
    let host = "localhost"
    func handler(request: HTTPRequest, response: HTTPResponse) {
        response.setHeader(.contentType, value: "text/plain")
        response.appendBody(string: greetings)
        response.completed()
    }

    override func setUpWithError() throws {
        var routes = Routes()
        routes.add(method: .get, uri: "/", handler: handler)
        httpServer = try HTTPServer.launch(wait: false, name: host, port: port, routes: routes)
    }

    override func tearDownWithError() throws {
        httpServer?.terminate()
    }

    func testExample() throws {
        guard let url = URL(string: "http://\(host):\(port)") else {
            XCTFail("invalid url")
            return
        }
        let exp = expectation(description: greetings)
        URLSession.shared.dataTask(with: URLRequest(url: url)) { data, _, error in
            XCTAssertNil(error)
            guard let data = data,
                  let text = String(data: data, encoding: .utf8) else {
                XCTFail("invalid response body")
                return
            }
            XCTAssertEqual(text, "Hello, world!")
            exp.fulfill()
        }.resume()
        wait(for: [exp], timeout: 10)
    }
}

```

[Access a tutorial](https://github.com/PerfectlySoft/PerfectDocs/blob/master/guide/gettingStarted.md) to help you get started using Perfect quickly. It includes straightforward examples of how Perfect can be used.

### Documentation
[Get started working with Perfect](https://github.com/PerfectlySoft/PerfectDocs), deploy your apps, and find more detailed help by consulting our reference library.
