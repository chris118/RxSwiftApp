//
//  ViewController.swift
//  RxSwiftApp
//
//  Created by xiaopeng on 2017/3/17.
//  Copyright © 2017年 putao. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa


class ViewController: UIViewController {
    
    @IBOutlet weak var textLabel: UILabel!
    
    let disposeBag = DisposeBag()
    var observable: Observable<String>?

    override func viewDidLoad() {

        super.viewDidLoad()
        
//        RxBasic()
//        rx_good()
//        rx_dispose()
//        rx_just()
//        rx_interval()
//        rx_repeatElement()
//        rx_observeOn()
//        rx_subscribeOn()
//        rx_ObserverOn_subscribeOn()
//        rx_map()
//        rx_scan()
//        rx_filter()
//        rx_debounce()
//        rx_flatmap()
//        rx_merg()
//        rx_zip()
//        rx_combineLastest()
//        rx_array_observerable()
//        rx_publishSubject()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //如果调用了onCompleted,和订阅者就断开了关系, 点击可以再次订阅
    @IBAction func subcribeTapped(_ sender: Any) {
        observable?.subscribe { (element) in
            print(Thread.current.name ?? "")
            print(element)
            }.addDisposableTo(disposeBag)
    }
    
    @IBAction func emitterTapped(_ sender: Any) {
        observable = Observable<String>.create { (observer) -> Disposable in
            
            DispatchQueue.global().async {
                Thread.sleep(forTimeInterval: 2)
                observer.onNext("Hello dummy 🐥")
                observer.onCompleted() //如果调用了onCompleted,和订阅者就断开了关系
            }
            return Disposables.create()
        }
    }

    func exampleOf(description: String, action: (Void) -> Void) {
        print("\n--- Example of:", description, "---")
        action()
    }
    
    func rx_dispose() {
        let observable = Observable<String>.create { (observer) -> Disposable in
            
            DispatchQueue.global().async {
                Thread.sleep(forTimeInterval: 2)
                observer.onNext("Hello dummy 🐣 delay 2 sec")
                observer.onCompleted()
            }
            
            observer.onNext("Hello dummy 🐣")
            //observer.onCompleted()
            
            //            Disposables.create()
            return Disposables.create {
                print("observable dispose")
            }
        }
        
        //let sub = observable.subscribe(onNext: { (element) in
        observable.subscribe(onNext: { (element) in
            print(element)
        }, onError: { (error) in
            print(error)
        }, onCompleted: {
            print("complete")
        }) {
            print("subscriber dispose")
            }.addDisposableTo(disposeBag)
        
        //sub.dispose()
    }
    
    func rx_just() {
        
        let observableJust = Observable<String>.just("Hello again dummy 🐥");
        observableJust.subscribe(onNext: { (element) in
            print(element)
        }).addDisposableTo(disposeBag)
        
        observableJust.subscribe(onCompleted: {
            print("I'm done")
        }).addDisposableTo(disposeBag)
    }
    
    func rx_interval() {
        let observableInteral = Observable<Int>.interval(0.3, scheduler: MainScheduler.instance)
        observableInteral.subscribe(onNext: { (element) in
            print(element)
        }).addDisposableTo(disposeBag)
    }

    func rx_repeatElement() {
        let observableRepeat = Observable<String>.repeatElement("This is fun 🙄")
        observableRepeat
            .take(3)
            .subscribe(onNext: { (element) in
                print(element)
            }).addDisposableTo(disposeBag)
    }
    
    func rx_observeOn() {
        observable = Observable<String>.create { (observer) -> Disposable in
            
            DispatchQueue.global().async {
                Thread.sleep(forTimeInterval: 2)
                observer.onNext("Hello dummy 🐥")
                observer.onCompleted()
            }
            return Disposables.create(){
                print("observable end")
            }
            }.observeOn(MainScheduler.instance) //切换到主线程
        
        observable?.subscribe(onNext: { value in
            print("\(value)")
            print(Thread.current)
            print(Thread.current.isMainThread)
        }).addDisposableTo(disposeBag)
    }
    
    func rx_subscribeOn() {
        observable = Observable<String>.create { (observer) -> Disposable in
            
            print(Thread.current)
            print(Thread.current.isMainThread)
            observer.onNext("Hello dummy 🐥")
            observer.onCompleted()
//
//            DispatchQueue.main.async {
//                Thread.sleep(forTimeInterval: 2)
//                observer.onNext("Hello dummy 🐥")
//                observer.onCompleted()
//            }
            return Disposables.create(){
                print("observable end")
            }
        }
        
        observable?
            //subscribeOn 的感染力很强，连 Observable 都能影响到。
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .userInteractive))
            .subscribe(onNext: { value in
            print("\(value)")
            print(Thread.current)
            print(Thread.current.isMainThread)
        }).addDisposableTo(disposeBag)
    }
    
    func rx_ObserverOn_subscribeOn() {
        observable = Observable<String>.create { (observer) -> Disposable in
            
            print("Observable \(Thread.current)")
            print(Thread.current.isMainThread)
            observer.onNext("Hello dummy 🐥")
            observer.onCompleted()
            return Disposables.create(){
                print("observable end")
            }
        }
        
        observable?
            //subscribeOn 的感染力很强，连 Observable 都能影响到。
            .observeOn(MainScheduler.instance)
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .userInteractive))

            .subscribe(onNext: { value in
                print("\(value)")
                print("subscribe \(Thread.current)")
                print(Thread.current.isMainThread)
            }).addDisposableTo(disposeBag)
    }
    
    func rx_map(){
        let observableMap = Observable<Int>.create { (observer) -> Disposable in
            observer.onNext(1)
            return Disposables.create()
        }
        
        let observableMap_Bool = observableMap.map { (element) -> Bool in
            if element == 0 {
                return false
            }else{
                return true
            }
        }
        
        observableMap_Bool.subscribe(onNext: { (element) in
            print(element)
        }) .addDisposableTo(disposeBag)
    }
    
    func rx_scan() {
        observable =  Observable<String>.create { (observer) -> Disposable in
            observer.onNext("D")
            observer.onNext("U")
            observer.onNext("M")
            observer.onNext("M")
            observer.onNext("Y")
            return Disposables.create()
        }
        
        observable?
            .scan("8", accumulator: { (one, two) -> String in
            return one + two
        })
            .subscribe(onNext: { (element) in
            print(element)
        }).addDisposableTo(disposeBag)
    }
    
    func rx_filter(){
    
        observable = Observable<String>.create({ (observer) -> Disposable in
            observer.onNext("🎁")
            observer.onNext("💩")
            observer.onNext("🎁")
            observer.onNext("💩")
            observer.onNext("💩")
            return Disposables.create()
        })
        
        observable?
            .filter({ (element) -> Bool in //just emit the 🎁
                if element == "🎁"{
                    return true
                }
                return false
            })
            .subscribe(onNext: {(element) in
                print(element)
        }).addDisposableTo(disposeBag)
        
    }
    
    func rx_debounce() {
        Observable<String>
            .of("a", "b", "c", "d", "e", "f")
            .debounce(1, scheduler: MainScheduler.instance)//1秒内其他事件到来都无效，最后一个生效
            .subscribe { print($0) }
            .addDisposableTo(disposeBag)
    }
    
    func rx_flatmap() {
        let sequenceInt = Observable.of(1, 2, 3)
        let sequenceString = Observable.of("A", "B", "--")
        
        sequenceInt
            .flatMap { _ in
                sequenceString
            }
            .subscribe {
                print($0)
        }.addDisposableTo(disposeBag)
    
    }
    
    func rx_merg(){
        let observable1 = Observable<String>.create({ (observer) -> Disposable in
            observer.onNext("🎁")
            observer.onNext("🎁")
            return Disposables.create()
        })
        
        let observable2 = Observable<String>.create({ (observer) -> Disposable in
            observer.onNext("💩")
            observer.onNext("💩")
            return Disposables.create()
        })
        
        Observable.of(observable1, observable2).merge()
            .subscribe {
                print($0)
        }.addDisposableTo(disposeBag)
    }
    
    func rx_zip(){
        let observable1 = Observable<String>.create({ (observer) -> Disposable in
            observer.onNext("🎁")
            observer.onNext("🎁")
            return Disposables.create()
        })
        
        let observable2 = Observable<String>.create({ (observer) -> Disposable in
            observer.onNext("💩")
            observer.onNext("💩")
            return Disposables.create()
        })
        
        Observable.zip(observable1, observable2) { (elements) -> String in

                return elements.0 + elements.1
            }
//            .subscribe {
//                print($0)
//            }
            .subscribe(onNext: {(element) in
                print(element)
            })
            .addDisposableTo(disposeBag)
    }
    
    func rx_cat(){
    
    }
    
    func rx_combineLastest(){
        let intOb1 = PublishSubject<String>()
        let intOb2 = PublishSubject<Int>()
        
        Observable.combineLatest(intOb1, intOb2) {
            "\($0) \($1)"
            }
            .subscribe {
                print($0)
        }.addDisposableTo(disposeBag)
        
        intOb1.on(.next("A"))
        intOb2.on(.next(1))
        intOb1.on(.next("B")) 
        intOb2.on(.next(2))
    }
    
    func rx_array_observerable(){
        let array = [1, 2, 3, 4, 5, 6]
        
        let arrayObserverable = Variable(array)
        
        arrayObserverable.asObservable()
   
            .flatMap { array -> Observable<Int> in
                
                
                let observable_new = Observable<Int>.create({ (observer) -> Disposable in
                    for item in array{
                        observer.onNext(item)
                    }
                    return Disposables.create()
                })
                
                return observable_new
            }
            .subscribe(onNext: { (element) in
                print(element)
            })
            .addDisposableTo(disposeBag)
    }
    
    func rx_publishSubject(){
        /*
          Cold Observable（以下简称 CO）只有在被订阅的时候才会发射事件，
         每次有新的订阅者都会把之前所有的事件都重新发射一遍； 
         
         Hot Observable（以下简称 HO）则是实时的，一旦有新的事件它就发射，
         不管有没有被订阅，而新的订阅者并不会接收到订阅前已经发射过的事件。
         */
        let subject = PublishSubject<String>()
        subject.subscribe { event in
            print("1->\(event)")
        }.addDisposableTo(disposeBag)
        
        subject.on(.next("a"))
        subject.on(.next("b"))
        
        
        subject.subscribe { event in
            print("2->\(event)") // don't print a and b
        }.addDisposableTo(disposeBag)
        
        subject.on(.next("c"))
    }
}

