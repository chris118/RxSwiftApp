//
//  ViewController1.swift
//  RxSwiftApp
//
//  Created by admin on 2017/3/19.
//  Copyright © 2017年 putao. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

extension ViewController {
    
    func RxBasic() -> Void {
        exampleOf(description: "just") {
            _ = Observable.just(32)
                .subscribe { element in
                    print(element)
            }
        }
        
        exampleOf(description: "just") {
            _ = Observable.just(32)
                .subscribe(onNext: { value in
                    print("\(value)")
                })
        }
        
        exampleOf(description: "just") {
            _ = Observable.just("hahahahha")
                .subscribe(onNext: { value in
                    print("\(value)")
                }, onError: { error in
                    print("\(error)")
                    
                }, onCompleted: {
                    print("finish")
                }, onDisposed: {
                    print("disposed")
                })
        }
        
        exampleOf(description: "of") {
            _ = Observable.of(1, 2)
                .subscribe(onNext: { value in
                    print("\(value)")
                })
        }
        
        exampleOf(description: "of") {
            Observable.of(1, 2)
                .subscribe(onNext: { value in
                    print("\(value)")
                }).dispose()
        }
        
        exampleOf(description: "of") {
            let disposeBag = DisposeBag()
            Observable.of(1, 2, 3)
                .subscribe(onNext: { value in
                    print("\(value)")
                }).addDisposableTo(disposeBag)
        }
        
        exampleOf(description: "Variable") {
            let disposeBag = DisposeBag()
            let number = Variable(1)
            number.asObservable()
                .subscribe {
                    print($0)
                }
                .addDisposableTo(disposeBag)
            number.value = 12
            number.value = 1_234_567
        }
        
        exampleOf(description: "map") {
            let disposeBag = DisposeBag()
            Observable.of(1, 2, 3)
                .map({
                    $0 * $0
                })
                .subscribe(onNext: { value in
                    print("\(value)")
                }).addDisposableTo(disposeBag)
        }
        
        
        exampleOf(description: "map") {
            let disposeBag = DisposeBag()
            Observable.of(1, 2, 3)
                .map({ value -> Int in
                    value * value
                })
                .subscribe(onNext: { value in
                    print("\(value)")
                }).addDisposableTo(disposeBag)
        }
        
        exampleOf(description: "flatMap") {
            let disposeBag = DisposeBag()
            struct Person {
                var name: Variable<String>
            }
            let scott = Person(name: Variable("Scott"))
            let lori = Person(name: Variable("Lori"))
            let person = Variable(scott)
            person.asObservable()
                .flatMap {
                    $0.name.asObservable()
                }
                .subscribe(onNext: { value in
                    print("\(value)")
                }).addDisposableTo(disposeBag)
            person.value = lori
            scott.name.value = "Eric"
        }
        
        exampleOf(description: "flatMap") {
            let disposeBag = DisposeBag()
            struct Person {
                var name: Variable<String>
            }
            let scott = Person(name: Variable("Scott"))
            let lori = Person(name: Variable("Lori"))
            let person = Variable(scott)
            person.asObservable()
                .flatMapLatest {
                    $0.name.asObservable()
                }
                .subscribe(onNext: { value in
                    print("\(value)")
                }).addDisposableTo(disposeBag)
            person.value = lori
            scott.name.value = "Eric" // Note: this will be ignor
        }
        
        
        exampleOf(description: "debug") {
            let disposeBag = DisposeBag()
            struct Person {
                var name: Variable<String>
            }
            let scott = Person(name: Variable("Scott"))
            let lori = Person(name: Variable("Lori"))
            let person = Variable(scott)
            person.asObservable()
                .debug("person")
                .flatMapLatest {
                    $0.name.asObservable()
                }
                .subscribe(onNext: { value in
                    print("\(value)")
                }).addDisposableTo(disposeBag)
            
            person.value = lori
            scott.name.value = "Eric" // Note: this will be ignor
        }
        
        exampleOf(description: "debug") {
            let disposeBag = DisposeBag()
            let searchString = Variable("iOS")
            searchString.asObservable()
                .map{$0.lowercased()}
                .distinctUntilChanged()
                .subscribe(onNext: { value in
                    print("\(value)")
                }).addDisposableTo(disposeBag)
            searchString.value = "IOS"
            searchString.value = "Rx"
            searchString.value = "ios" // ignor
            searchString.value = "ios" // ignor
            searchString.value = "ios" // ignor
        }
        
        exampleOf(description: "takeWhile") {
            let disposeBag = DisposeBag()
            Observable.of(1, 2, 3, 4, 5, 6, 7, 8, 9)
                .takeWhile{$0 < 5}
                .subscribe(onNext: { value in
                    print("\(value)")
                }).addDisposableTo(disposeBag)
        }
        
        exampleOf(description: "scan") {
            Observable.of(1, 2, 3, 4, 5)
                .scan(20, accumulator: +)
                .subscribe(onNext: { print($0) })
                .dispose()
        }
        
        
        exampleOf(description: "catchErrorJustReturn") {
            struct CommonError: Error {
                let error1: String
            }
            
            let disposeBag = DisposeBag()
            
            let sequenceThatFails = PublishSubject<String>()
            
            sequenceThatFails
                .catchErrorJustReturn("😊")
                .subscribe { print($0) }
                .disposed(by: disposeBag)
            
            sequenceThatFails.onNext("💏")
            sequenceThatFails.onNext("😨")
            sequenceThatFails.onNext("😡")
            sequenceThatFails.onNext("🔴")
            sequenceThatFails.onError(RxError.unknown)
            sequenceThatFails.onNext("💏")
        }
        
        exampleOf(description: "range") {
            let observable = Observable.range(start: 1, count: 10)
            observable
                .subscribe(onNext: {
                    print($0)
                }).dispose()
        }
        
        exampleOf(description: "repeat") {
            let observable = Observable.repeatElement("💏")
            observable
                .take(3)
                .subscribe(onNext: {
                    print($0)
                }).dispose()
        }
    }
    
    func rx_good() {
        Observable<NSDate>.create { (observer) -> Disposable in
            
            DispatchQueue.global().async {
                while true {
                    Thread.sleep(forTimeInterval: 0.01)
                    observer.onNext(NSDate())
                }
            }
            return Disposables.create()
            }
            // We want to update on the main thread
            .observeOn(MainScheduler.instance)
            // We only want time intervals divisble by two, because why not
            .filter { (date) -> Bool in
                return Int(date.timeIntervalSince1970) % 2 == 0
            }
            // We're mapping a date to some UIColor
            .map { (date) -> UIColor in
                let interval : Int = Int(date.timeIntervalSince1970)
                let color1 = CGFloat( Double(((interval * 1) % 255)) / 255.0)
                let color2 = CGFloat( Double(((interval * 2) % 255)) / 255.0)
                let color3 = CGFloat( Double(((interval * 3) % 255)) / 255.0)
                
                return UIColor(red: color1, green:color2, blue: color3, alpha: 1)
            }.subscribe(onNext: {(color) in
                self.textLabel.backgroundColor = color
            }).addDisposableTo(disposeBag)
    }
}
