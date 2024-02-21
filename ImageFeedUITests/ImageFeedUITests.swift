//
//  ImageFeedUITests.swift
//  ImageFeedUITests
//
//  Created by Kirill Sklyarov on 19.02.2024.
//

import XCTest

final class ImageFeedUITests: XCTestCase {
    private let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }
    
    func testAuth() throws {
        // Тесты авторизации
        
        // Нажать кнопку авторизации
        app.buttons["Autentificate"].tap()
        
        // Подождать, пока экран авторизации открывается и загружается
        let webView = app.webViews["UnsplashWebView"]
        XCTAssertTrue(webView.waitForExistence(timeout: 5))
        
        // Ввести данные в форму
        let loginTextField = webView.descendants(matching: .textField).element
        loginTextField.tap()
        loginTextField.typeText("k.sklyarov@yandex.ru")
        
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        passwordTextField.tap()
        passwordTextField.typeText("bft-MKp-zb2-Yzr")
        
        // Нажать кнопку логина
        webView.swipeUp()
        webView.buttons["Login"].tap()
        
        // Подождать, пока открывается экран ленты
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(cell.waitForExistence(timeout: 5))
        print(app.debugDescription)
    }
    
    func testFeed() throws {
        // тут будут тесты ленты фоток
        
        // Подождать, пока отрывается и загружается экран ленты
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        
        // Сделать жест "смахивания" вверх по экрану для его скролла
        cell.swipeUp()
        
        sleep(2)
        
        // Поставить лайк в ячейке верхней картинки
        let cellToLike = tablesQuery.children(matching: .cell).element(boundBy: 1)
                sleep(2)
        
        cellToLike.buttons["No Active"].tap()
        sleep(2)
        
        // Отменить лайк в ячейке верхней картинки
        cellToLike.buttons["Active"].tap()
        
        // Нажать на верхнюю картинку
        cellToLike.tap()
        
        // Подождать, пока картинка открывается на весь экран
        sleep(2)
        
        // Увеличить картинку
        let image = app.scrollViews.images.element(boundBy: 0)
        image.pinch(withScale: 3, velocity: 1)
        
        // Уменьшить картинку
        image.pinch(withScale: 0.5, velocity: -1)
        
        // Вернуть экран ленты
        let navBackButton = app.buttons["back_button"]
        navBackButton.tap()
    }
    
    func testProfile() throws {
        // тут будут тесты профиля
        
        // Подождать пока открывается и загружается экран ленты
        sleep(2)
        
        // Перейти на экран профиля
        app.tabBars.buttons.element(boundBy: 1).tap()
        
        // Проверить что на нем отображаются ваши персональные данные
        XCTAssertTrue(app.staticTexts["Name Label"].exists)
        XCTAssertTrue(app.staticTexts["NickName Label"].exists)
        XCTAssertTrue(app.staticTexts["Text Label"].exists)
        
        
        // Нажать кнопку логаута
        let logoutButton = app.buttons["logoutButton"]
        logoutButton.tap()
        
        // Нажать на Да в алерте
        app.alerts["Пока, пока!"].scrollViews.otherElements.buttons["Да"].tap()
        
        // Проверить что открылся экран авторизации
        let authView = app.otherElements["AuthViewController"]
        XCTAssertTrue(authView.waitForExistence(timeout: 1))
        
    }
}
