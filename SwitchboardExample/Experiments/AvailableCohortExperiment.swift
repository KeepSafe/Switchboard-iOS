//
//  AvailableCohortExperiment.swift
//  SwitchboardExample
//
//  Created by Rob Phillips on 10/20/17.
//  Copyright © 2017 Keepsafe Software Inc. All rights reserved.
//

import Switchboard

final class AvailableCohortExperiment: SwitchboardExperiment {

    override class func populateAvailableCohorts() {
        SwitchboardExperiment.namesMappedToCohorts["availableCohortExperiment"] = ["control", "cohort1", "cohort2"]
    }

}
