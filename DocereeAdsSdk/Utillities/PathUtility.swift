//
//  PathUtility.swift
//  DocereeAdsSdk
//
//  Created by Muqeem.Ahmad on 26/04/22.
//  Copyright © 2022 Doceree. All rights reserved.
//

import Foundation


// MARK: Archiving paths
let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
let ArchivingUrl = DocumentsDirectory.appendingPathComponent("platformuid")
let DocereeAdsIdArchivingUrl = DocumentsDirectory.appendingPathComponent("DocereeAdsId")

