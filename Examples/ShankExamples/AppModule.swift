//
//  AppModule.swift
//  ShankExamples
//
//  Created by Basem Emara on 2019-09-07.
//  Copyright © 2019 Zamzam Inc. All rights reserved.
//

import Foundation
import Shank

struct AppModule: Module {
    
    init() {
        shared { SomeObject() as SomeObjectType }
        shared { AnotherObject() as AnotherObjectType }
        make { AnotherObject() as AnotherObjectType }
        make { SomeObject() as SomeObjectType }
        make { SomeObject() as SomeObjectType }
        viewModel { SomeViewModel() as ViewModelObjectType }
    }
}

protocol SomeObjectType {}
protocol AnotherObjectType {}
struct SomeObject: SomeObjectType {}
struct AnotherObject: AnotherObjectType {}

protocol ViewModelObjectType {}
struct SomeViewModel: ViewModelObjectType {
    @Inject
    var someObject: SomeObjectType
    
    @Inject
    var anotherObject: AnotherObjectType
}
