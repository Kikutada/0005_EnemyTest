//
//  GameGhost.swift
//  0005_EnemyTest
//
//  Created by Kikutada on 2020/08/24.
//  Copyright © 2020 Kikutada All rights reserved.
//

import Foundation
import UIKit

class CgGhostBlinky : CgGhost {
    
    enum EnGhostAction {
        case None, Stopping, Walking, Turning, EatingDot, EatingPower, EatingFruit
    }

    override init(binding object: CgSceneFrame, deligateActor: ActorDeligate) {
        super.init(binding: object, deligateActor: deligateActor)
        actor = .Blinky
        sprite_number = actor.getSpriteNumber()
    }
    
    // ============================================================
    //   Core operation methods for actor
    //  - Sequence: reset()->start()->update() called->stop()
    // ============================================================

    /// Reset player states and draw at default position
    override func reset() {
        super.reset()

        position.set(column: 13, row: 21, dx: 4)
        direction.set(to: .Left)
        state.set(to: .Stop)
        draw2()
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
        draw2()
    }

    /// Update handler
    /// - Parameter interval: Interval time(ms) to update
    override func update(interval: Int) {
        if !state.isSpurt() {
            if deligateActor.isGhostSpurt() {
                state.setSpurt()
            }
        }
        super.update(interval: interval)
    }
    
    // ============================================================
    //  General methods in this class
    // ============================================================

    //
    //  プレイフィールド上の右上付近を動き回る
    //
    override func toScatter() {
        target.set(column: 25, row: 35)
        super.toScatter()
    }

    //
    //  常にパックマンのいるマス(8dotx8dot)を追う
    //
    func setChase(playerPosition: CgPosition) {
        guard !state.isFrightened() else { return }
        self.setChase(targetPosition: playerPosition)
    }

    override func setStartTargetPosition() {
        target.set(column: 13, row: 18, dx: 4, dy: -4)
    }

}


//---------------------------------------------------------------------------
class CgGhostState : CbContainer {

    enum EnGhostState {
        case None, Stop, Standby, ReadyToScatter, Scatter, Chase, Frightened, ReturnFromFrightened, Escape, ReturnFromEscape
        
        func isFrightenedState() -> Bool {
            return self == .Frightened || self == .ReturnFromFrightened
        }
        
        func isEscapeState() -> Bool {
            return self == .Escape || self == .ReturnFromEscape
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

    
    func reset() {
        currentState = .None
        nextState = .None
        frightenedState = false
        frightenedBlinkingState = false
        frightenedBlinkingOn = false
        spurtState = false
        timer_frightenedState?.reset()
        timer_frightenedStateWhileBlinking?.reset()
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
            timer_frightenedState?.set(interval: time)
            timer_frightenedState?.start()
        }
    }
    
    func isFinishFrightened() -> Bool {
        return (timer_frightenedState?.isEventFired())!
    }

    func pauseFrightened(_ on: Bool) {
        if on {
            timer_frightenedState?.pause()
            timer_frightenedStateWhileBlinking?.pause()
        } else {
            timer_frightenedState?.start()
            timer_frightenedStateWhileBlinking?.start()
        }
    }

    func isFrightenedBlinkingState() -> Bool {
        return frightenedBlinkingState
    }
    
    func isFrightenedBlinkingOn() -> Bool {
        return (timer_frightenedStateWhileBlinking?.get())! > 10*16
    }

    func isFrightened() -> Bool {
        return frightenedState && !isEscape()
    }

    private func updateFrightenedState() {
        if !frightenedBlinkingState {
            if timer_frightenedState.get() <= 2000 {
                timer_frightenedStateWhileBlinking.set(interval: 20*16)
                timer_frightenedStateWhileBlinking.start()
                frightenedBlinkingState = true
            }
        } else {
            if timer_frightenedStateWhileBlinking.get() == 20*16 {
                frightenedBlinkingOn = true
                updateDarwing = true
            } else if timer_frightenedStateWhileBlinking.get() == 10*16 {
                frightenedBlinkingOn = false
                updateDarwing = true
            }
            if timer_frightenedStateWhileBlinking.isEventFired() {
                timer_frightenedStateWhileBlinking.set(interval: 21*16)
                timer_frightenedStateWhileBlinking.start()
            }
        }
        if timer_frightenedState.isEventFired() {
            setFrightened(false)
        }
    }

    func isEscape() -> Bool { return currentState == .Escape || nextState == .Escape || currentState == .ReturnFromEscape || nextState == .ReturnFromEscape }

    func update() {
        if currentState != nextState {
            currentState = nextState
            updateDarwing = true
        }
    }

    func isChanging() -> Bool {
        return ( currentState != nextState && nextState != .None)
    }
    
    func isDrawingUpdated() -> Bool {
        return updateDarwing
    }
    
    func clearDrawingUpdate() {
        updateDarwing = false
    }
}

class CgGhost : CgActor {
    enum EnGhostAction: Int {
        case None, Walking, Spurting, Frightened, Warping, Standby, Escaping
    }

    enum EnMovementRestrictions {
        case None, OnlyVertical, OnlyHorizontal
    }

    var target: CgPosition = CgPosition()
    var state: CgGhostState!

    var movementRestriction: EnMovementRestrictions = .None

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
        speedTotal = 0
        movementRestriction = .None
    }

    override func stop() {
        sprite.stopAnimation(sprite_number)
    }
    
    /// Update handler
    /// - Parameter interval: Interval time(ms) to update
    override func update(interval: Int) {

        if state.isChanging() {
            switch state.getNext() {
                case .Standby: toStandby()
                case .ReadyToScatter:  toReadyScatter()
                case .Scatter:  toScatter()
                case .Chase:  toChase()
                case .Escape:  toEscape()
                case .ReturnFromEscape:  toEscapeEnd()
                default:   toDefault()
            }
            state.update()
        }

        switch state.get() {
            case .Standby: movingStandby()
            case .ReadyToScatter:  movingReadyScatter()
            case .Scatter:
                if state.isFrightened() {
                    movingByRandom()
                } else {
                    movingScatter()
                }
            case .Chase:
                if state.isFrightened() {
                    movingByRandom()
                } else {
                    movingChase()
                }
            case .Escape:  movingEscape()
            case .ReturnFromEscape:  movingEscapeEnd()
            default: movingByRandom()
        }

        if state.isChanging() || direction.isChanging() || state.isDrawingUpdated() {
            direction.update()
            draw()
            state.clearDrawingUpdate()
        }

        sprite.setPosition(sprite_number, x: position.x, y: position.y)
    }
    
    // ============================================================
    //  General methods in this class
    // ============================================================

    private var speedTotal: Int = 0
    private var speed: Int = 0

    func setSpeed(speed: Int) {
        self.speed = speed
    }

    func calculateSpeed() -> Int {
        speedTotal += speed
        let result = speedTotal / speedUnit
        speedTotal = speedTotal % speedUnit
        return result
    }

    func getTargetDirection() -> EnDirection {
        var direction: EnDirection

        let delta_x = target.x - position.x
        let delta_y = target.y - position.y
        
        if delta_x == 0 && delta_y == 0 {
            return .Stop
        }

        if abs(delta_x) > abs(delta_y) {
            direction = delta_x > 0 ? .Right : .Left
        } else {
            direction = delta_y > 0 ? .Up : .Down
        }
        
        return direction
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

    
    func setStartTargetPosition() {
        // pure virtual
    }

    func setSpeed(direction: EnDirection, oneWayProhibition: Bool = true) {
        let road = deligateActor.getTileAttribute(to: direction, column: position.column,row: position.row)
        let _oneWayProhibition = oneWayProhibition && (road == .Oneway && direction == .Up)

        if (road == .Wall) /*|| (road == .Gate)*/ || _oneWayProhibition {
            //
        } else {
            // true
            if state.isFrightened() && !(state.get() == .ReadyToScatter) {
                setSpeed(speed: deligateActor.getGhostSpeed(action: .Frightened) )
            } else {
                if (road == .Slow) {
                    setSpeed(speed: deligateActor.getGhostSpeed(action: .Warping) )
                } else {
                    if state.isSpurt() {
                        setSpeed(speed: deligateActor.getGhostSpeed(action: .Spurting) )
                    } else {
                        setSpeed(speed: deligateActor.getGhostSpeed(action: .Walking) )
                    }
                }
            }
        }
    }


    func move(direction: EnDirection, speed: Int) {
        if direction != .Stop {
            position.move2(to: direction, speed: speed )
        }
    }

    func move(direction: EnDirection) {
        if direction != .Stop {
            position.move2(to: direction, speed: calculateSpeed() )
        }
    }

    func getTargetHorizontalDirection() -> EnDirection {
        var walk: EnDirection = .Stop
        let dx_t = (position.column - target.column)*8 + (position.dx - target.dx)

        if dx_t > 0 {
            walk = .Left
        } else if dx_t < 0 {
            walk = .Right
        }
        return walk
    }

    func getTargetVerticalDirection() -> EnDirection {
        var walk: EnDirection = .Stop
        let dy_t = (position.row - target.row)*8 + (position.dy - target.dy)
        
        if dy_t > 0 {
            walk = .Down
        } else if dy_t < 0 {
            walk = .Up
        }
        return walk
    }

    func getDistanceToTargetPosition(direction: EnDirection) -> Int {
        let deltaColumn = position.column + direction.getHorizaontalDelta() - target.column
        let deltaRow = position.row + direction.getVerticalDelta() - target.row

        return deltaColumn * deltaColumn + deltaRow * deltaRow
    }
    
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

    // ============================================================
    //  Draw and clear sprite methods.
    // ============================================================

    func toStandby() {
        setSpeed(speed: deligateActor.getGhostSpeed(action: .Standby) )
    }

    func toReadyScatter() {
        setSpeed(speed: deligateActor.getGhostSpeed(action: .Standby) )
        target.set(column: 13, row: 21, dx: 4)
        if position.movingVertical() && movementRestriction == .None {
            movementRestriction = .OnlyVertical
        } else {
            movementRestriction = .None
        }
    }

    func toScatter() {
        switch state.get() {
            case .None:
                break
            case .Chase:
                self.direction.set(to: self.direction.get().getReverse())
                self.direction.update()
            case .ReadyToScatter:
                var _direction = getTargetHorizontalDirection()
                if _direction == .Stop { _direction = .Left }
                direction.set(to: _direction)
            default: break
        }
    }

    func toChase() {
        switch state.get() {
            case .Scatter:
                self.direction.set(to: self.direction.get().getReverse())
                self.direction.update()
            default: break
        }
    }

    func toEscape() {
        sprite.stopAnimation(sprite_number)
        target.set(column: 13, row: 21, dx: 4)
    }

    func toEscapeEnd() {
        setStartTargetPosition()
    }

    func toDefault() {
        //
    }
    
    // ============================================================
    //  Draw and clear sprite methods.
    // ============================================================
    func movingStandby() {
        if direction.get() == .Up {
            if !position.checkHalfDyUp() {
                self.move(direction: direction.get())
            } else {
                direction.set(to: direction.get().getReverse())
            }
        } else if direction.get() == .Down {
            if !position.checkHalfDyDown() {
                self.move(direction: direction.get())
            } else {
                direction.set(to: direction.get().getReverse())
            }
        } else {
            direction.set(to: .Up)
        }
    }


    func movingReadyScatter() {

        // 縦方向だけ移動し、真ん中にくるまで待つ
        if movementRestriction == .OnlyVertical {
            movingStandby()
            if !position.movingVertical() {
                movementRestriction = .None
            }
            return
        }
        
        //
        let dirH = getTargetHorizontalDirection()
        let dirV = getTargetVerticalDirection()
        
        if dirH != .Stop {
            if dirH == direction.get() {
                self.move(direction: direction.get())
            } else {
                direction.set(to: dirH)
            }
        } else if dirV != .Stop {
            if dirV == direction.get() {
                self.move(direction: direction.get())
            } else {
                direction.set(to: dirV)
            }
        } else {
            movementRestriction = .None
            state.set(to: .Scatter)
        }
    }

    func movingEscapeEnd() {

        let dirH = getTargetHorizontalDirection()
        let dirV = getTargetVerticalDirection()
        
        if dirV != .Stop {
            if dirV == direction.get() {
                self.move(direction: direction.get())
            } else {
                direction.set(to: dirV)
            }
        } else if dirH != .Stop {
            if dirH == direction.get() {
                self.move(direction: direction.get())
            } else {
                direction.set(to: dirH)
            }
        } else {
            movementRestriction = .OnlyHorizontal
            state.setFrightened(false)  // delete & hit
            state.set(to: .ReadyToScatter)
        }
    }
    
    //
    //
    //
    func movingScatter() {
        let nextDirection = decideDirectionByTarget(oneWayProhibition: true)

        setSpeed(direction: nextDirection)
        let speed = calculateSpeed()
        if speed == 0 { return }

        direction.set(to: nextDirection)
        self.move(direction: nextDirection, speed: speed)
    }

    //
    //
    //
    func movingChase() {
        movingScatter()
    }

    //
    //
    //
    func movingEscape() {
        if getTargetDirection() == .Stop {
            state.set(to: .ReturnFromEscape)
        } else {
            let nextDirection = decideDirectionByTarget(oneWayProhibition: false)
            direction.set(to: nextDirection)
            self.move(direction: nextDirection)
        }
    }
    
    func movingByRandom() {
        
        var nextDirection: EnDirection = direction.getNext()
        setSpeed(direction: nextDirection)

        let speed = calculateSpeed()
        if speed == 0 { return }

        if canMove(direction: nextDirection) {
            self.move(direction: nextDirection, speed: speed)
        } else {
            nextDirection = decideDirectionByRandom()
            direction.set(to: nextDirection)
            self.move(direction: nextDirection, speed: speed)
        }
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

    

    func setChase(targetPosition: CgPosition) {
        if state.get() == .Scatter || state.get() == .Chase {
            state.set(to: .Chase)
            target.set(column: targetPosition.column, row: targetPosition.row)
        }
    }

    func setScatter() {
        if state.get() == .Chase {
            state.set(to: .Scatter)
        }
    }
    
    func setFrightened(time: Int) {
        if state.isEscape() {
            // 巣に逃げている状態で、更にパワーエサを食べたときは何もしない
            return
        } else {
            state.setFrightened(true, interval: time)
            setSpeed(speed: deligateActor.getGhostSpeed(action: .Frightened) )
            direction.set(to: direction.get().getReverse())
            draw()
        }
    }
    
    func setEscape() {
        state.set(to: .Escape)
        setSpeed(speed: deligateActor.getGhostSpeed(action: .Escaping) )
    }
    

    // ============================================================
    //  Draw and clear sprite methods.
    // ============================================================

    /// Draw and animate  player in the direction
    /// - Parameter direction: Direction
    func draw2() {
        let texture1 = actor.rawValue*16+direction.get().rawValue*2+64
        sprite.draw(sprite_number, x: position.x, y: position.y, texture: texture1)
    }


    func draw() {

        if state.isFrightened() {
            if !state.isFrightenedBlinkingState()  {
                sprite.startAnimation(sprite_number, sequence: [72,73], timePerFrame: 0.1, repeat: true)
            } else {
                if state.isFrightenedBlinkingOn() {
                    sprite.startAnimation(sprite_number, sequence: [74,75], timePerFrame: 0.1, repeat: true)
                } else {
                    sprite.startAnimation(sprite_number, sequence: [72,73], timePerFrame: 0.1, repeat: true)
                }
            }
        } else {
            if state.isEscape() {
                switch direction.get() {
                    case .Right: sprite.draw(sprite_number, x: position.x, y: position.y, texture: 88)
                    case .Left:  sprite.draw(sprite_number, x: position.x, y: position.y, texture: 89)
                    case .Up:    sprite.draw(sprite_number, x: position.x, y: position.y, texture: 90)
                    case .Down:  sprite.draw(sprite_number, x: position.x, y: position.y, texture: 91)
                    default:     sprite.draw(sprite_number, x: position.x, y: position.y, texture: 88)
                }
            } else {
//                let texture1 =
//                let texture2 =
                switch direction.get() {
                    case .Right: sprite.startAnimation(sprite_number, sequence: [64+16*actor.rawValue,65+16*actor.rawValue], timePerFrame: 0.12, repeat: true)
                    case .Left:  sprite.startAnimation(sprite_number, sequence: [66+16*actor.rawValue,67+16*actor.rawValue], timePerFrame: 0.12, repeat: true)
                    case .Up:    sprite.startAnimation(sprite_number, sequence: [68+16*actor.rawValue,69+16*actor.rawValue], timePerFrame: 0.12, repeat: true)
                    case .Down:  sprite.startAnimation(sprite_number, sequence: [70+16*actor.rawValue,71+16*actor.rawValue], timePerFrame: 0.12, repeat: true)
                    default:     sprite.startAnimation(sprite_number, sequence: [70+16*actor.rawValue,71+16*actor.rawValue], timePerFrame: 0.12, repeat: true)
                }
            }
        }
    }

    func clear() {
        sprite.stopAnimation(sprite_number)
        sprite.clear(sprite_number)
    }

    //
    // ターゲットポジションに標準表示
    //
    func drawTargetPosition() {
        let targetActor: EnActor = actor.getTarget()
        let spriteNumber = targetActor.getSpriteNumber()

        switch state.get() {
            case .ReadyToScatter: fallthrough
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


