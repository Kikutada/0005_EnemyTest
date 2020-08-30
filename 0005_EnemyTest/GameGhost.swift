//
//  GameGhost.swift
//  0005_EnemyTest
//
//  Created by Kikutada on 2020/08/24.
//  Copyright © 2020 Kikutada All rights reserved.
//

import Foundation
import UIKit

/// Ghost Blinky class
class CgGhostBlinky : CgGhost {

    override init(binding object: CgSceneFrame, deligateActor: ActorDeligate) {
        super.init(binding: object, deligateActor: deligateActor)
        actor = .Blinky
        sprite_number = actor.getSpriteNumber()
    }
    
    // ============================================================
    //   Core operation methods for actor
    //  - Sequence: reset()->start()->update() called->stop()
    // ============================================================

    /// Reset ghopst states and draw at default position
    override func reset() {
        super.reset()
        position.set(column: 13, row: 21, dx: 4)
        direction.set(to: .Left)
        state.set(to: .Scatter)
        draw()
    }

    /// Start
    override func start() {
        super.start()
        state.set(to: .Scatter)
    }
        
    /// Stop
    override func stop() {
        super.stop()
        direction.set(to: .Stop)
        draw()
    }

    // ============================================================
    //  General methods in this class
    // ============================================================

    /// Chase player to enter chase state.
    /// Always chase the Pacman during the chase mode.
    /// - Parameter playerPosition: Player's position
    func chase(playerPosition: CgPosition) {
        guard !state.isFrightened() else { return }
        super.setStateToChase(targetPosition: playerPosition)
    }
    
    /// Set the target position in scatter mode.
    /// Blinky moves around the upper right in the play field.
    override func entryActionToScatter() {
        target.set(column: 25, row: 35)
        super.entryActionToScatter()
    }

    /// Set return destination in nest from Escape mode.
    override func entryActionToEscapeInNest() {
        target.set(column: 13, row: 18, dx: 4, dy: -4)
    }

}

/// Ghost Pinky class
class CgGhostPinky : CgGhost {
    
    override init(binding object: CgSceneFrame, deligateActor: ActorDeligate) {
        super.init(binding: object, deligateActor: deligateActor)
        actor = .Pinky
        sprite_number = actor.getSpriteNumber()
    }

    // ============================================================
    //   Core operation methods for actor
    //  - Sequence: reset()->start()->update() called->stop()
    // ============================================================

    /// Reset ghopst states and draw at default position
    override func reset() {
        super.reset()
        position.set(column: 13, row: 18, dx: 4)
        direction.set(to: .Down)
        state.set(to: .Standby)
        draw()
    }

    // ============================================================
    //  General methods in this class
    // ============================================================

    /// Chase player to enter chase state.
    /// Aiming for Pacman's third destination
    /// - Parameters:
    ///   - playerPosition: Player's position
    ///   - playerDirection: Player's direction
    func chase(playerPosition: CgPosition, playerDirection: EnDirection) {
        guard !state.isFrightened() else { return }
        let dx = playerDirection.getHorizaontalDelta()*3
        let dy = playerDirection.getVerticalDelta()*3
        let newTargetPosition = CgPosition(column: playerPosition.column+dx, row: playerPosition.row+dy)
        super.setStateToChase(targetPosition: newTargetPosition)
    }

    /// Set the target position in scatter mode.
    /// Pinky moves around the upper left on the play field.
    override func entryActionToScatter() {
        target.set(column: 2, row: 35)
        super.entryActionToScatter()
    }
    
    /// Set return destination in nest from Escape mode.
    override func entryActionToEscapeInNest() {
        target.set(column: 13, row: 18, dx: 4, dy: -4)
    }

}

/// Ghost Inky class
class CgGhostInky : CgGhost {
    
    override init(binding object: CgSceneFrame, deligateActor: ActorDeligate) {
        super.init(binding: object, deligateActor: deligateActor)
        actor = .Inky
        sprite_number = actor.getSpriteNumber()
    }

    // ============================================================
    //   Core operation methods for actor
    //  - Sequence: reset()->start()->update() called->stop()
    // ============================================================

    /// Reset ghopst states and draw at default position
    override func reset() {
        super.reset()
        position.set(column: 11, row: 18, dx: 4)
        direction.set(to: .Up)
        state.set(to: .Standby)
        draw()
    }

    // ============================================================
    //  General methods in this class
    // ============================================================

    /// Chase player to enter chase state.
    /// Aiming for a point-symmetrical mass centered on Blinky and Pacman.
    /// - Parameters:
    ///   - playerPosition: Player's position
    ///   - blinkyPosition: Blinky's position
    func chase(playerPosition: CgPosition, blinkyPosition: CgPosition) {
        guard !state.isFrightened() else { return }
        let dx = playerPosition.column - blinkyPosition.column
        let dy = playerPosition.row - blinkyPosition.row
        let newTargetPosition = CgPosition(column: playerPosition.column+dx, row: playerPosition.row+dy)
        super.setStateToChase(targetPosition: newTargetPosition)
    }

    /// Set the target position in scatter mode.
    /// Inky moves around the lower right on the play field.
    override func entryActionToScatter() {
        target.set(column: 27, row: 0)
        super.entryActionToScatter()
    }
    
    /// Set return destination in nest from Escape mode.
    override func entryActionToEscapeInNest() {
        target.set(column: 11, row: 18, dx: 4, dy: -4)
    }

}

/// Ghost Clyde class
class CgGhostClyde : CgGhost {
    
    private var chaseMode = false
    
    override init(binding object: CgSceneFrame, deligateActor: ActorDeligate) {
        super.init(binding: object, deligateActor: deligateActor)
        actor = .Clyde
        sprite_number = actor.getSpriteNumber()
    }

    // ============================================================
    //   Core operation methods for actor
    //  - Sequence: reset()->start()->update() called->stop()
    // ============================================================

    /// Reset ghopst states and draw at default position
    override func reset() {
        super.reset()
        chaseMode = false
        position.set(column: 15, row: 18, dx: 4)
        direction.set(to: .Up)
        state.set(to: .Standby)
        draw()
    }

    // ============================================================
    //  General methods in this class
    // ============================================================

    /// Chase player to enter chase state.
    /// If Clyde is outside the radius of 130 dots from Pacman, it has the character of a Blinky,
    /// otherwise Clyde moves by random within the radius regardless of Pacman.
    func chase(playerPosition: CgPosition) {
        guard !state.isFrightened() else { return }
        let dx = playerPosition.x - position.x
        let dy = playerPosition.y - position.y
        if (dx*dx+dy*dy) > 130*130 {
            super.setStateToChase(targetPosition: playerPosition)
            chaseMode = true
        } else {
            chaseMode = false
        }
    }
    
    /// Set the target position in scatter mode.
    /// Clyde moves around the lower left on the play field.
    override func entryActionToScatter() {
        target.set(column: 0, row: 0)
        super.entryActionToScatter()
    }

    /// Set return destination in nest from Escape mode.
    override func entryActionToEscapeInNest() {
        target.set(column: 13+2, row: 18, dx: 4, dy: -4)
    }

    /// Clyde switches scatter and random movement in chase mode.
    override func doActionInChase() {
        if chaseMode {
            doActionInScatter()
        } else {
            doActionInFrightened()
        }
    }
    
}

//------------------------------------------------------------
// Common class for ghosts
//------------------------------------------------------------

/// State of ghosts class
class CgGhostState : CbContainer {

    enum EnGhostState {
        case None, Stop, Standby, GoOut, Scatter, Chase, Frightened,
             Escape, EscapeInNest
        
        func isFrightenedState() -> Bool {
            return self == .Frightened
        }
        
        func isEscapeState() -> Bool {
            return self == .Escape || self == .EscapeInNest
        }
    }

    private var currentState: EnGhostState = .None
    private var nextState: EnGhostState = .None

    private var frightenedState: Bool = false
    private var frightenedBlinkingState: Bool = false
    private var timer_frightenedState: CbTimer!
    private var timer_frightenedStateWhileBlinking: CbTimer!
    private var frightenedBlinkingOn: Bool = false

    private var spurtState: Bool = false
    private var updateDarwing: Bool = false
    
    override init(binding object: CbObject) {
        super.init(binding: object)
        timer_frightenedState = CbTimer(binding: self)
        timer_frightenedStateWhileBlinking = CbTimer(binding: self)
    }

    override func update(interval: Int) {
        if frightenedState {
            updateFrightenedState()
        }
    }

    private func updateFrightenedState() {
        if !frightenedBlinkingState {
            if timer_frightenedState.get() <= 2000 { // ms
                timer_frightenedStateWhileBlinking.set(interval: 20*16)  // ms
                timer_frightenedStateWhileBlinking.start()
                frightenedBlinkingState = true
            }
        } else {
            if timer_frightenedStateWhileBlinking.get() == 20*16 { // ms
                frightenedBlinkingOn = true
                updateDarwing = true
            } else if timer_frightenedStateWhileBlinking.get() == 10*16 { // ms
                frightenedBlinkingOn = false
                updateDarwing = true
            }
            if timer_frightenedStateWhileBlinking.isEventFired() {
                timer_frightenedStateWhileBlinking.set(interval: 21*16)  // ms
                timer_frightenedStateWhileBlinking.start()
            }
        }
        if timer_frightenedState.isEventFired() {
            setFrightened(false)
        }
    }

    func reset() {
        currentState = .None
        nextState = .None
        frightenedState = false
        frightenedBlinkingState = false
        frightenedBlinkingOn = false
        spurtState = false
        timer_frightenedState.reset()
        timer_frightenedStateWhileBlinking.reset()
        updateDarwing = false
    }

    func get() -> EnGhostState {
        return currentState
    }

    func getNext() -> EnGhostState {
        return nextState
    }

    func set(to state: EnGhostState) {
        nextState = state
    }

    func update() {
        if currentState != nextState {
            currentState = nextState
            updateDarwing = true
        }
    }

    func isChanging() -> Bool {
        return ( currentState != nextState && nextState != .None)
    }
    
    func setSpurt() {
        spurtState = true
        updateDarwing = true
    }
    
    func isSpurt() -> Bool {
        return spurtState
    }

    func setFrightened(_ on: Bool, interval time: Int = 0) {
        frightenedState = on
        frightenedBlinkingState = false
        updateDarwing = true
        if on {
            timer_frightenedState.set(interval: time)
            timer_frightenedState.start()
        }
    }
    
    func isFinishFrightened() -> Bool {
        return timer_frightenedState.isEventFired()
    }

    func pauseFrightened(_ on: Bool) {
        if on {
            timer_frightenedState.pause()
            timer_frightenedStateWhileBlinking.pause()
        } else {
            timer_frightenedState.start()
            timer_frightenedStateWhileBlinking.start()
        }
    }

    func isFrightenedBlinkingState() -> Bool {
        return frightenedBlinkingState
    }
    
    func isFrightenedBlinkingOn() -> Bool {
        return timer_frightenedStateWhileBlinking.get() > 10*16 // ms
    }

    func isFrightened() -> Bool {
        return frightenedState && !isEscape()
    }

    func isEscape() -> Bool { return currentState == .Escape || nextState == .Escape || currentState == .EscapeInNest || nextState == .EscapeInNest }

    func isDrawingUpdated() -> Bool {
        return updateDarwing
    }
    
    func clearDrawingUpdate() {
        updateDarwing = false
    }
}

/// Based ghost actor class
class CgGhost : CgActor {

    enum EnGhostAction {
        case None, Walking, Spurting, Frightened, Warping, Standby, GoingOut, Escaping
    }

    enum EnMovementRestrictions {
        case None, OnlyVertical, OnlyHorizontal
    }

    var target: CgPosition = CgPosition()
    var state: CgGhostState!

    private var movementRestriction: EnMovementRestrictions = .None

    override init(binding object: CgSceneFrame, deligateActor: ActorDeligate) {
        super.init(binding: object, deligateActor: deligateActor)
        state = CgGhostState(binding: self)
        enabled = false
    }

    // ============================================================
    //   Core operation methods for actor
    //  - Sequence: reset()->start()->update() called->stop()
    // ============================================================

    /// Reset player states and draw at default position
    override func reset() {
        super.reset()
        direction.reset()
        state.reset()
        movementRestriction = .None
    }

    override func stop() {
        sprite.stopAnimation(sprite_number)
    }
    
    /// Update handler
    /// - Parameter interval: Interval time(ms) to update
    override func update(interval: Int) {

        //
        // Entry Action to state
        //
        if state.isChanging() {
            switch state.getNext() {
                case .Standby: break
                case .GoOut: entryActionToGoOut()
                case .Scatter: entryActionToScatter()
                case .Chase: entryActionToChase()
                case .Escape: entryActionToEscape()
                case .EscapeInNest: entryActionToEscapeInNest()
                default: break
            }
            state.update()
        }

        //
        // Do Action in state
        //
        switch state.get() {
            case .Standby: doActionInStanby()
            case .GoOut:  doActionInGoOut()
            case .Scatter:
                if state.isFrightened() {
                    doActionInFrightened()
                } else {
                    doActionInScatter()
                }
            case .Chase:
                if state.isFrightened() {
                    doActionInFrightened()
                } else {
                    doActionInChase()
                }
            case .Escape:  doActionInEscape()
            case .EscapeInNest:  doActionInEscapeInNest()
            default: break
        }

        //  Update direction and sprite animation for changes.
        if state.isChanging() || direction.isChanging() || state.isDrawingUpdated() {
            direction.update()
            draw()
            state.clearDrawingUpdate()
        }

        // Update position.
        sprite.setPosition(sprite_number, x: position.x, y: position.y)
    }
    
    // ============================================================
    //  Entry action to enter each state.
    // ============================================================
    func entryActionToGoOut() {
        // Ghost moves out of the nest.
        target.set(column: 13, row: 21, dx: 4)
        movementRestriction = (position.dy != 0 && movementRestriction == .None) ? .OnlyVertical : .None
    }

    func entryActionToScatter() {
        switch state.get() {
            case .None:
                break
            case .Chase:
                updateDirection(to: direction.get().getReverse())
            case .GoOut:
                var nextDirection = getTargetDirection(selected: .Horizontal)
                if nextDirection == .Stop { nextDirection = .Left }
                updateDirection(to: nextDirection)
        default:
                break
        }
    }

    func entryActionToChase() {
        switch state.get() {
            case .Scatter:
                updateDirection(to: direction.get().getReverse())
            default:
                break
        }
    }

    func entryActionToEscape() {
        target.set(column: 13, row: 21, dx: 4)
        sprite.stopAnimation(sprite_number)
    }

    func entryActionToEscapeInNest() {
        // pure virtual
    }

    // ============================================================
    //  Do action in state.
    // ============================================================
    /// Ghost moves up and down in the nest.
    func doActionInStanby() {
        var speed = getGhostSpeed(action: .Standby)
        let currentDirectrion = direction.get()

        while(speed > 0) {
            if (currentDirectrion == .Up && position.dy != HALF_MAZE_UNIT) || (currentDirectrion == .Down && position.dy != -HALF_MAZE_UNIT) {
                speed = position.move(to: currentDirectrion, speed: speed)
            } else {
                direction.set(to: currentDirectrion.getReverse())
                break
            }
        }

    }

    func doActionInGoOut() {
        // Ghost moves only vertically and waits until it is in the middle position.
        if movementRestriction == .OnlyVertical {
            doActionInStanby()
            if position.dy == 0 {
                movementRestriction = .None
            }
            return
        }

        // Ghost moves out of the nest.
        var speed = getGhostSpeed(action: .GoingOut)

        while(speed > 0) {
            let horizontalDirection = getTargetDirection(selected: .Horizontal)
            let currentDirectrion = horizontalDirection != .Stop ? horizontalDirection : getTargetDirection(selected: .Vertiacal)
            
            if currentDirectrion != .Stop {
                if currentDirectrion == direction.get() {
                    speed = position.move(to: direction.get(), speed: speed)
                } else {
                    direction.set(to: currentDirectrion)
                    break
                }
            } else {
                state.set(to: .Scatter)
                break
            }
        }
    }

    func doActionInEscapeInNest() {
        // Ghost moves out of the nest.
        var speed = getGhostSpeed(action: .Escaping)

        while(speed > 0) {
            let verticalDirection = getTargetDirection(selected: .Vertiacal)
            let currentDirectrion = verticalDirection != .Stop ? verticalDirection : getTargetDirection(selected: .Horizontal)
            
            if currentDirectrion != .Stop {
                if currentDirectrion == direction.get() {
                    speed = position.move(to: direction.get(), speed: speed)
                } else {
                    direction.set(to: currentDirectrion)
                    break
                }
            } else {
                state.setFrightened(false)
                state.set(to: .Standby)
                break
            }
        }
    }
    
    func doActionInScatter() {
        var speed = getGhostSpeed(action: .Walking)
        var nextDirection = direction.get()

        if position.amountMoved > 0 {
            nextDirection = decideDirectionByTarget(oneWayProhibition: true)
            direction.set(to: nextDirection)
            if direction.isChanging() {
                position.amountMoved = 0
            }
        }
        
        while(speed > 0) {
            if canMove(direction: nextDirection, oneWayProhibition: true) {
                speed = position.move(to: nextDirection, speed: speed)
            } else {
                position.roundDown(to: .Stop)
                break
            }
        }
    }

    func doActionInChase() {
        doActionInScatter()
    }

    func doActionInEscape() {
        if getTargetDirection() == .Stop {
            state.set(to: .EscapeInNest)
        } else {

            var speed = getGhostSpeed(action: .Escaping)
            var nextDirection = direction.get()

            if position.amountMoved > 0 {
                nextDirection = decideDirectionByTarget(oneWayProhibition: false)
                direction.set(to: nextDirection)
                if direction.isChanging() {
                    position.amountMoved = 0
                }
            }
            
            while(speed > 0) {
                if canMove(direction: nextDirection, oneWayProhibition: false) {
                    speed = position.move(to: nextDirection, speed: speed)
                } else {
                    position.roundDown(to: .Stop)
                    break
                }
            }

        }
    }
    
    func doActionInFrightened() {
        var speed = getGhostSpeed(action: .Frightened)
        var nextDirection = direction.getNext()

        while(speed > 0) {
            if canMove(direction: nextDirection, oneWayProhibition: true) {
                speed = position.move(to: nextDirection, speed: speed)
            } else {
                nextDirection = decideDirectionByRandom()
                direction.set(to: nextDirection)
                position.roundDown(to: .Stop)
                break
            }
        }

    }

    // ============================================================
    //  Change state methods
    // ============================================================
    func setStateToGoOut() {
        if state.get() == .Standby {
            state.set(to: .GoOut)
        }
    }
    
    func setStateToChase(targetPosition: CgPosition) {
        if state.get() == .Scatter || state.get() == .Chase {
            state.set(to: .Chase)
            target.set(column: targetPosition.column, row: targetPosition.row)
        }
    }

    func setStateToScatter() {
        if state.get() == .Chase {
            state.set(to: .Scatter)
        }
    }
    
    func setStateToFrightened(time: Int) {
        if !state.isEscape() {
            state.setFrightened(true, interval: time)
            direction.set(to: direction.get().getReverse())
            draw()
        } else {
            // While ghost is escaping to the nest, it doesn't change if eating more power food.
        }
    }
    
    func setStateToEscape() {
        state.set(to: .Escape)
    }

    // ============================================================
    //  General methods
    // ============================================================
    func getGhostSpeed(action: EnGhostAction) -> Int {
        return deligateActor.getGhostSpeed(action: action, spurt: state.isSpurt())
    }

    func updateDirection(to nextDirection: EnDirection) {
        if direction.get() != nextDirection {
            direction.set(to: nextDirection)
            direction.update()
            position.roundDown(to: .Stop)
            position.amountMoved = 1
        }
    }

    func canMove(direction: EnDirection, oneWayProhibition: Bool = true) -> Bool {
        var can = true
        if position.canMove(direction: direction) {
            let road = deligateActor.getTileAttribute(to: direction, column: position.column,row: position.row)
            
            if (road == .Wall) {
                can = false
            } else if oneWayProhibition && (road == .Oneway && direction == .Up) {
                can = false
            }
        } else {
            can = false
        }
        return can
    }

    enum EnTargetDirection {
        case All, Horizontal, Vertiacal
    }

    func getTargetDirection(selected: EnTargetDirection = .All) -> EnDirection {
        var direction: EnDirection = .Stop
        let delta_x = target.x - position.x
        let delta_y = target.y - position.y
        
        switch selected {
            case .All:
                if delta_x != 0 || delta_y != 0 {
                    if abs(delta_x) > abs(delta_y) {
                        direction = delta_x > 0 ? .Right : .Left
                    } else {
                        direction = delta_y > 0 ? .Up : .Down
                    }
                }

            case .Horizontal:
                if delta_x < 0 {
                    direction = .Left
                } else if delta_x > 0 {
                    direction = .Right
                }

            case .Vertiacal:
                if delta_y < 0 {
                    direction = .Down
                } else if delta_y > 0 {
                    direction = .Up
                }
        }
        
        return direction
    }

    /// Ghost decides the next direction to chase target position.
    /// - Parameters:
    ///   - oneWayProhibition: True prohibits that ghost move through one way.
    ///   - forcedDirectionChange: True changes the direction the ghost is moving
    /// - Returns: Next direction to move
    func decideDirectionByTarget(oneWayProhibition: Bool, forcedDirectionChange: Bool = false) -> EnDirection {
        let currentDirection = direction.get()
        var nextDirection: EnDirection  = .None

        if position.isCenter() || forcedDirectionChange {
            let allDirections: [EnDirection] = [.Up, .Down, .Left, .Right]
            var minDistance = MAZE_MAX_DISTANCE

            for _direction in allDirections {
                if _direction != currentDirection.getReverse() || forcedDirectionChange {
                    if canMove(direction: _direction, oneWayProhibition: oneWayProhibition) {
                        let distance = getDistanceToTargetPosition(direction: _direction)
                        if distance < minDistance {
                            minDistance = distance
                            nextDirection = _direction
                        }
                    }
                }
            }
           
            if nextDirection == .None {
                nextDirection = currentDirection.getReverse()
            }
        } else {
            nextDirection = currentDirection
        }

        return nextDirection
    }

    private func getDistanceToTargetPosition(direction: EnDirection) -> Int {
        let deltaColumn = position.column + direction.getHorizaontalDelta() - target.column
        let deltaRow = position.row + direction.getVerticalDelta() - target.row

        return deltaColumn * deltaColumn + deltaRow * deltaRow
    }
    
    func decideDirectionByRandom() -> EnDirection {
        var nextDirection = direction.get().getRandom()

        for _ in 1 ..< 3 {
            while !canMove(direction: nextDirection) {
                nextDirection = nextDirection.getClockwise()
            }
            if nextDirection != direction.get().getReverse() { break }
        }
        return nextDirection
    }

    // ============================================================
    //  Draw and clear sprite methods.
    // ============================================================
    func draw() {
        if enabled == false {
            // Stopped ghost
            let texture1 = actor.rawValue*16+direction.get().rawValue*2+64
            sprite.draw(sprite_number, x: position.x, y: position.y, texture: texture1)

        } else if state.isFrightened() {
            // Frightened ghost
            if !state.isFrightenedBlinkingState()  {
                sprite.startAnimation(sprite_number, sequence: [72,73], timePerFrame: 0.1, repeat: true)
            } else {
                if state.isFrightenedBlinkingOn() {
                    sprite.startAnimation(sprite_number, sequence: [74,75], timePerFrame: 0.1, repeat: true)
                } else {
                    sprite.startAnimation(sprite_number, sequence: [72,73], timePerFrame: 0.1, repeat: true)
                }
            }

        } else if state.isEscape() {
            // Escaping ghost
            let texture1 = direction.get().rawValue+88
            sprite.draw(sprite_number, x: position.x, y: position.y, texture: texture1)

        } else {
            // Walking ghost
            let texture1 = actor.rawValue*16+direction.get().rawValue*2+64
            let texture2 = texture1 + 1
            sprite.startAnimation(sprite_number, sequence: [texture1,texture2], timePerFrame: 0.12, repeat: true)
        }
    }

    func clear() {
        sprite.stopAnimation(sprite_number)
        sprite.clear(sprite_number)
    }

    /// Draw at target position
    func drawTargetPosition() {
        let targetActor: EnActor = actor.getTarget()
        let spriteNumber = targetActor.getSpriteNumber()

        switch state.get() {
            case .GoOut: fallthrough
            case .Scatter: fallthrough
            case .Escape: fallthrough
            case .Chase:
                if state.isFrightened() {
                    sprite.clear(spriteNumber)
                } else {
                    sprite.draw(spriteNumber, x: target.x, y: target.y, texture: 79+actor.rawValue*16)
                    sprite.setDepth(spriteNumber, zPosition: targetActor.getDepth())
                }
            default:
                sprite.clear(spriteNumber)
        }
    }

}
