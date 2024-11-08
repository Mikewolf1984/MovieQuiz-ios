//
//  MovieQuizUITests.swift
//  MovieQuizUITests
//
//  Created by Михаил Волков on 08.11.2024.
//

import XCTest
@testable import MovieQuiz

final class MovieQuizUITests: XCTestCase {

    var app: XCUIApplication!
        
        override func setUpWithError() throws {
            try super.setUpWithError()
            
            app = XCUIApplication()
            app.launch()
            
            // это специальная настройка для тестов: если один тест не прошёл,
            // то следующие тесты запускаться не будут; и правда, зачем ждать?
            continueAfterFailure = false
        }
        override func tearDownWithError() throws {
            try super.tearDownWithError()
            
            app.terminate()
            app = nil
        }

    @MainActor
    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    @MainActor
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
    
    @MainActor
    func testYesButton() {
        sleep(3)
        let firstPoster = app.images["Poster"] // находим первоначальный постер
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        
        app.buttons["Yes"].tap() // находим кнопку `Да` и нажимаем её
        sleep(3)
        let secondPoster = app.images["Poster"] // ещё раз находим постер
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        
        XCTAssertFalse(firstPosterData == secondPosterData) // проверяем, что постеры разные
        
    }
    
    func testIndex() {
        
        let indexLabel = app.staticTexts["Index"]
        
        XCTAssertEqual(indexLabel.label, "1/10")
    }
    
    func testNoButton() {
        sleep(3)
        let firstPoster = app.images["Poster"] // находим первоначальный постер
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        
        app.buttons["No"].tap() // находим кнопку `Да` и нажимаем её
        sleep(3)
        let secondPoster = app.images["Poster"] // ещё раз находим постер
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        
        XCTAssertFalse(firstPosterData == secondPosterData) // проверяем, что постеры разные
        
    }
    
    func testFinalAlert() {
        for _ in 1...10 {
            sleep(3)
            app.buttons["No"].tap() // находим кнопку `Да` и нажимаем её
        }
    sleep(3)
        let alert = app.alerts["finalOrErrorAlert"]
        XCTAssertTrue(alert.exists)
        XCTAssertTrue(alert.label == "Этот раунд окончен!")
        XCTAssertTrue(alert.buttons.firstMatch.label == "Сыграть ещё раз")
        
    }
   
}
