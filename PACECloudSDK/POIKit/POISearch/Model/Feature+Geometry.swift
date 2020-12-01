//
//  Feature+Geometry.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import CoreGraphics
import Foundation

// Documentation see https://github.com/mapbox/vector-tile-spec/tree/master/2.1 chapter 4.3

extension VectorTile_Tile.Feature {
    struct Command {
        var type: POIKit.CommandType
        var point: CGPoint
    }

    func processGeometry() -> [Command] {
        var commandType: POIKit.CommandType?
        var count: Int?
        var parameters = [Int]()
        var commands = [Command]()

        for (index, value) in geometry.enumerated() {
            guard let type = commandType, let cnt = count else {
                let command = extractCommandTypeAndCount(from: value)
                count = command.count
                commandType = command.type

                continue
            }

            guard parameters.count < type.paramCount * cnt else {
                commands.append(contentsOf: convertToCommands(commandType: type, params: parameters))

                let command = extractCommandTypeAndCount(from: value)
                commandType = command.type
                count = command.count

                parameters = [Int]()

                continue
            }

            let param = (Int((value >> 1)) ^ (-(-Int(value) & 1)))
            parameters.append(param)

            if index == geometry.count - 1 {
                commands.append(contentsOf: convertToCommands(commandType: type, params: parameters))
            }
        }

        return convertPoints(for: commands)
    }

    private func extractCommandTypeAndCount(from value: UInt32) -> (type: POIKit.CommandType?, count: Int) {
        return (type: POIKit.CommandType(rawValue: Int(value & 0x7)),
                count: Int(value >> 3))
    }

    private func convertToCommands(commandType: POIKit.CommandType, params: [Int]) -> [Command] {
        var points = [CGPoint]()

        var i = 0
        while i < params.count {
            points.append(CGPoint(x: params[i],
                                  y: params[i + 1]))
            i += 2
        }

        return points.map({ Command(type: commandType, point: $0) })
    }

    private func convertPoints(for commands: [Command]) -> [Command] {
        var newCommands = [Command]()

        for command in commands {
            guard let previous = newCommands.last else {
                newCommands.append(command)
                continue
            }

            let point = CGPoint(x: command.point.x + previous.point.x,
                                y: command.point.y + previous.point.y)
            newCommands.append(Command(type: command.type, point: point))
        }

        return newCommands
    }

}
