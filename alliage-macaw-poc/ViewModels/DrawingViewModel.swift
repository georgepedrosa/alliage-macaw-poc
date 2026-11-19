//
//  DrawingViewModel.swift
//  alliage-macaw-poc
//
//  Created by George Pedrosa on 11/11/26.
//  Copyright © 2021 Vitor Muniz. All rights reserved.
//

import Foundation
import Macaw

/// Owns the annotation drawing state: the active tool, the Macaw scene graph of
/// shapes, the stroke lifecycle for the shape being drawn, selection and text
/// editing. The view controller only binds UIKit components to the observable
/// state and forwards canvas touches here.
final class DrawingViewModel {

    // MARK: - Bindable state

    let activeTool = Observable<Annotation.Types>(.none)
    let isSelectionModeActive = Observable<Bool>(false)
    let isScrollEnabled = Observable<Bool>(false)
    let isTextEditingActive = Observable<Bool>(false)

    // MARK: - Scene graph

    /// Group node where all drawn shapes are stored.
    let shapesGroup = Group()

    /// Root node containing the shapes group and the drawing canvas.
    private var rootNode = Group()

    /// When true the canvas sits on top of the shapes to receive drawing
    /// touches; when false the shapes sit on top so they can be selected.
    private var isDrawingActive = true

    // MARK: - Selection and text state

    var lastActiveShape: CustomShape?
    var customTexts: [CustomText] = []

    /// Updated by the view controller from keyboard notifications.
    var isKeyboardVisible = false

    /// Color used for new shapes; mirrors the color selector popup.
    var strokeColorValue = ColorSelectorViewModel.defaultColorValue

    /// Annotation id of the currently selected shape, if any.
    var activeAnnotationId: Int? {
        guard let shape = lastActiveShape, shape.isActive else { return nil }
        return shape.annotationId
    }

    // MARK: - Stroke in progress

    private var shapeInProgress: CustomShape?
    private var strokeStartPoint = Point()
    private var isNewShape = true
    private var multilineTimer: ParkBenchTimer?
    private var isLastMultilinePoint = false
    private var nextAnnotationId = 0

    private let strokeWidth = 5.0
    private let multilineEndTapInterval = 0.5

    // MARK: - Scene setup

    /// Builds the root node rendered by the Macaw view. The canvas is created
    /// by the view because its size depends on the screen.
    func makeSceneRoot(canvas: Shape) -> Group {
        rootNode = Group(contents: [shapesGroup, canvas])
        return rootNode
    }

    // MARK: - Tools

    func selectTool(_ tool: Annotation.Types) {
        isScrollEnabled.value = false
        activeTool.value = .none
        isSelectionModeActive.value = false
        isNewShape = true
        setDrawingActive(true)
        activeTool.value = tool
    }

    func toggleSelectionMode() {
        setSelectionMode(!isSelectionModeActive.value)
    }

    func setSelectionMode(_ active: Bool) {
        activeTool.value = .none
        isSelectionModeActive.value = active
        setDrawingActive(!active)
        isNewShape = true
    }

    private func setDrawingActive(_ active: Bool) {
        guard active != isDrawingActive else { return }
        isDrawingActive = active
        let first = rootNode.contents.remove(at: 0)
        rootNode.contents.append(first)
    }

    // MARK: - Canvas touches

    func canvasTouchBegan(at location: Point?) {
        if isSelectionModeActive.value {
            deselectActiveShape()
            return
        }

        guard let location = location else { return }

        let stroke = Stroke(fill: Color(val: strokeColorValue), width: strokeWidth)
        strokeStartPoint = location

        if isNewShape {
            nextAnnotationId += 1
        }

        switch activeTool.value {
        case .none:
            return
        case .freeDrawing:
            shapeInProgress = FreeDrawing(startPoint: location, lastPoint: location, stroke: stroke, type: .freeDrawing, annotationId: nextAnnotationId)
            if let shape = lastActiveShape, shape.isActive {
                shape.isActive = false
            }
        case .text:
            shapeInProgress = CustomText(text: "", startPoint: location, lastPoint: location, stroke: stroke, type: .text, annotationId: nextAnnotationId, comment: "")
        case .line:
            shapeInProgress = CustomLine(startPoint: location, lastPoint: location, stroke: stroke, type: .line, annotationId: nextAnnotationId, comment: "")
        case .ellipse:
            shapeInProgress = CustomEllipse(startPoint: location, lastPoint: location, stroke: stroke, type: .ellipse, annotationId: nextAnnotationId, comment: "")
        case .rect:
            shapeInProgress = CustomRect(startPoint: location, lastPoint: location, stroke: stroke, type: .rect, annotationId: nextAnnotationId, comment: "")
        case .arrow:
            shapeInProgress = Arrow(startPoint: location, lastPoint: location, stroke: stroke, type: .arrow, annotationId: nextAnnotationId, comment: "")
        case .protractor:
            shapeInProgress = Protractor(p0: location, p1: location, p2: location, delegate: self, stroke: stroke, type: .protractor, annotationId: nextAnnotationId, comment: "")
        case .asterisk:
            shapeInProgress = Asterisk(startPoint: location, lastPoint: location, stroke: stroke, type: .asterisk, annotationId: nextAnnotationId, comment: "")
        case .arc:
            shapeInProgress = CustomArc(p0: location, p1: location, p2: location, delegate: self, stroke: stroke, type: .arc, annotationId: nextAnnotationId, comment: "")
        case .multiline:
            guard isNewShape else {
                continueMultiline(at: location)
                return
            }
            shapeInProgress = Multiline(startPoint: location, lastPoint: location, stroke: stroke, type: .multiline, annotationId: nextAnnotationId)
            multilineTimer = ParkBenchTimer()
            isLastMultilinePoint = false
        }

        guard let newShape = shapeInProgress else { return }
        setLastActiveShape(newShape: newShape)
        shapesGroup.contents.append(newShape)
    }

    func canvasTouchMoved(to location: Point) {
        guard activeTool.value != .none, !isSelectionModeActive.value, let shape = shapeInProgress else { return }

        shape.updateForm(startPoint: strokeStartPoint, lastPoint: location)
        if activeTool.value == .freeDrawing {
            // Free drawing grows segment by segment from the last touched point.
            strokeStartPoint = location
        }
    }

    func canvasTouchEnded() {
        if isSelectionModeActive.value { return }

        switch activeTool.value {
        case .none:
            return
        case .text:
            finishTextStroke()
        case .multiline:
            finishMultilineStroke()
        default:
            finishDefaultStroke()
        }
    }

    // MARK: - Stroke completion

    private func finishTextStroke() {
        if isKeyboardVisible {
            isTextEditingActive.value = false
            return
        }
        guard let customText = shapeInProgress as? CustomText else { return }

        customText.delegate = self
        customTexts.append(customText)
        customText.setTransformEvents()
        isTextEditingActive.value = true
        setSelectionMode(true)
    }

    /// A tap shortly after the previous one ends the multiline; otherwise the
    /// tap added a new segment and drawing continues.
    private func continueMultiline(at location: Point) {
        guard let multiline = shapeInProgress as? Multiline, let timer = multilineTimer else { return }

        if timer.stop() < multilineEndTapInterval {
            isNewShape = true
            isLastMultilinePoint = true
        } else {
            multiline.newPoint(point: location)
            multilineTimer = ParkBenchTimer()
        }
    }

    private func finishMultilineStroke() {
        guard let multiline = shapeInProgress as? Multiline, isNewShape else { return }

        if isLastMultilinePoint {
            isNewShape = true
            if multiline.points.count == 1 {
                deleteShape(node: multiline)
            }
            setSelectionMode(true)
        } else {
            multiline.delegate = self
            multiline.setTransformEvents()
            setTapEvent(node: multiline)
            isNewShape = false
        }
    }

    private func finishDefaultStroke() {
        guard let shape = shapeInProgress else { return }

        if let freeDrawing = shape as? FreeDrawing {
            selectShape(node: freeDrawing)
        }
        shape.delegate = self
        shape.setTransformEvents()
        setTapEvent(node: shape)
        setSelectionMode(true)
    }

    // MARK: - Shape selection and removal

    private func setTapEvent(node: CustomShape) {
        node.onTap { [weak self] event in
            guard let self = self else { return }
            if self.activeTool.value == .none && !self.isSelectionModeActive.value { return }
            guard let tapped = event.node as? CustomShape else { return }
            self.selectShape(node: tapped)
        }
    }

    func selectShape(node: CustomShape) {
        node.isActive = !node.isActive
        if node.isActive {
            // Moves the active shape to the top of the drawn shapes.
            shapesGroup.contents.removeAll { $0.hash == node.hash }
            shapesGroup.contents.append(node)
        }
        setLastActiveShape(newShape: node)
    }

    func deleteShape(node: CustomShape) {
        shapesGroup.contents.removeAll { $0.hash == node.hash }
    }

    func deleteActiveShape() {
        guard let shape = lastActiveShape, shape.isActive else { return }
        deleteShape(node: shape)
        lastActiveShape = nil
    }

    private func deselectActiveShape() {
        lastActiveShape?.isActive = false
        lastActiveShape = nil
    }

    // MARK: - Coloring

    func applyColor(_ color: Color, toAnnotationId annotationId: Int?) {
        guard let annotationId = annotationId else { return }
        let shape = shapesGroup.contents
            .compactMap { $0 as? CustomShape }
            .first { $0.annotationId == annotationId }
        guard let target = shape else { return }

        target.updateStroke(stroke: Stroke(fill: color, width: target.stroke.width), stroke2: nil)
    }

    // MARK: - Text editing

    var editingText: String? {
        return customTexts.last?.textNode.text
    }

    /// Applies the typed text to the text shape being edited, wrapping or
    /// growing its bounds as needed, and returns the text to display back.
    func updateEditingText(_ text: String) -> String? {
        guard let customText = customTexts.last else { return nil }

        customText.setText(text: text)
        if customText.textNode.bounds.h > customText.rectLimit.form.bounds().h {
            customText.updateBoundsHeight()
        }
        if customText.textNode.bounds.w > customText.rectLimit.form.bounds().w {
            let unwrappedText = customText.textNode.text
            customText.setText(text: unwrappedText.breakingLastWord())
            if customText.textNode.bounds.w > customText.rectLimit.form.bounds().w {
                customText.updateBoundsWidth()
                customText.setText(text: unwrappedText)
            }
            if customText.textNode.bounds.h > customText.rectLimit.form.bounds().h {
                customText.updateBoundsHeight()
            }
        }
        return customText.textNode.text
    }

    func endTextEditing(with text: String) {
        guard text.isEmpty, let customText = customTexts.last else { return }
        deleteShape(node: customText)
    }
}

// MARK: - ShapeInteractionDelegate

extension DrawingViewModel: ShapeInteractionDelegate {

    func activateScrollView(enable: Bool) {
        isScrollEnabled.value = enable
    }

    var isEditingText: Bool {
        get { return isTextEditingActive.value }
        set { isTextEditingActive.value = newValue }
    }

    /// Deselects the previously selected shape and stores the new one.
    func setLastActiveShape(newShape: CustomShape) {
        guard newShape.isActive else {
            lastActiveShape = nil
            return
        }
        if let previous = lastActiveShape {
            if previous.isHidden {
                previous.isActive = false
                previous.isHidden = true
            } else {
                previous.isActive = false
            }
        }
        lastActiveShape = newShape
    }
}
