# Shank

A Swift micro-library that provides lightweight dependency injection.

```swift
struct MyStruct {

    @Inject(module: TestModule())
    var someObject: SomeObjectType
    
    @Inject(module: TestModule())
    var anotherObject: AnotherObjectType
    
    init() {
        TestModule().resolve()
    }
}

struct TestModule: Module {
    
    func resolve() {
        single { SomeObject() as SomeObjectType }
        single { AnotherObject(someObject: self.resolve()) as AnotherObjectType }
        factory { SomeViewModel() as ViewModelObjectType }
    }
}
```
