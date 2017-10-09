//
//  ActiveFeature1.swift
//  SwitchboardExample
//
//  Created by Rob Phillips on 10/9/17.
//  Copyright © 2017 Keepsafe Software Inc. All rights reserved.
//

import Switchboard

final class ActiveFeature1: SwitchboardFeature {

    var someValue: String?  { return values?["someValue"] as? String }

}
