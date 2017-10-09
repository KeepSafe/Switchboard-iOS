//
//  ActiveExperiment1.swift
//  SwitchboardExample
//
//  Created by Rob Phillips on 10/9/17.
//  Copyright © 2017 Keepsafe Software Inc. All rights reserved.
//

import Switchboard

final class ActiveExperiment1: SwitchboardExperiment {

    var lovesLamp: Bool?    { return values["iLoveLamp"] as? Bool }

}
