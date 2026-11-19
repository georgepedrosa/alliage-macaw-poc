//
//  ViewController.swift
//  alliage-macaw-poc
//
//  Created by Victor Sukochev on 02/03/2017.
//  Copyright © 2017 Exyte. All rights reserved.
//

import UIKit
import Macaw

/// Annotation drawing screen. All drawing state and rules live in
/// DrawingViewModel; this controller only binds UIKit components to the view
/// model and forwards user input (buttons, canvas touches, keyboard, text).
class ViewController: UIViewController {

    // MARK: - Outlets

    @IBOutlet weak var buttonsStackView: UIStackView!
    @IBOutlet weak var imageScrollView: UIScrollView!

    @IBOutlet weak var colorButton: UIButton!
    @IBOutlet weak var freeButton: UIButton!
    @IBOutlet weak var textButton: UIButton!
    @IBOutlet weak var lineButton: UIButton!
    @IBOutlet weak var rectButton: UIButton!
    @IBOutlet weak var circleButton: UIButton!
    @IBOutlet weak var protractorButton: UIButton!
    @IBOutlet weak var arcButton: UIButton!
    @IBOutlet weak var arrowButton: UIButton!
    @IBOutlet weak var asteriskButton: UIButton!
    @IBOutlet weak var multilineButton: UIButton!
    @IBOutlet weak var selectionButton: UIButton!
    @IBOutlet weak var handButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!

    // MARK: - View models

    private let viewModel = DrawingViewModel()
    private let colorSelectorViewModel = ColorSelectorViewModel()

    // MARK: - Subviews

    private let backgroundView = UIView()
    private let imageView = UIImageView()
    private let macawView = MacawView()

    private var colorSelectorPopup: ColorSelectorPopup!
    private var selectorBackground: UIView!

    private let messageInputContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()

    private let inputTextView = UITextView()

    private var bottomConstraint: NSLayoutConstraint?

    /// Rectangle shape where new shapes are drawn.
    private var canvas: Shape!

    /// Tool buttons indexed by the tool they activate, used to reflect the
    /// active tool in the buttons' selected state.
    private var toolButtons: [Annotation.Types: UIButton] = [:]

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupScrollView()
        setupBackgroundView()
        setupMacawView()
        setupCanvasEvents()
        setupInputContainer()
        setupColorSelector()
        bindViewModel()
    }

    // MARK: - View model binding

    private func bindViewModel() {
        toolButtons = [
            .freeDrawing: freeButton,
            .text: textButton,
            .line: lineButton,
            .rect: rectButton,
            .ellipse: circleButton,
            .protractor: protractorButton,
            .arc: arcButton,
            .arrow: arrowButton,
            .asterisk: asteriskButton,
            .multiline: multilineButton
        ]

        viewModel.activeTool.bindAndFire { [weak self] tool in
            self?.toolButtons.forEach { $1.isSelected = ($0 == tool) }
        }

        viewModel.isSelectionModeActive.bindAndFire { [weak self] isActive in
            self?.selectionButton.isSelected = isActive
        }

        viewModel.isScrollEnabled.bindAndFire { [weak self] isEnabled in
            self?.imageScrollView.isScrollEnabled = isEnabled
            self?.imageScrollView.pinchGestureRecognizer?.isEnabled = isEnabled
        }

        viewModel.isTextEditingActive.bind { [weak self] isActive in
            if isActive {
                self?.inputTextView.becomeFirstResponder()
            } else {
                self?.inputTextView.resignFirstResponder()
            }
        }

        // New shapes are drawn with the color last picked in the selector.
        colorSelectorViewModel.selectedColorValue.bindAndFire { [weak self] colorValue in
            self?.viewModel.strokeColorValue = colorValue
        }

        colorSelectorViewModel.onCancel = { [weak self] in
            self?.selectorBackground.isHidden = true
        }

        colorSelectorViewModel.onConfirm = { [weak self] color, annotationId in
            self?.viewModel.applyColor(color, toAnnotationId: annotationId)
            self?.selectorBackground.isHidden = true
        }
    }

    // MARK: - Setup

    private func setupScrollView() {
        imageScrollView.delegate = self
        imageScrollView.bounces = false
        imageScrollView.bouncesZoom = false
        imageScrollView.minimumZoomScale = 1.0
    }

    private func setupBackgroundView() {
        imageScrollView.addSubview(backgroundView)

        backgroundView.snp.makeConstraints { make in
            make.center.equalTo(imageScrollView)
            make.size.equalTo(imageScrollView)
        }

        imageView.backgroundColor = .darkGray

        imageScrollView.contentSize = CGSize(width: backgroundView.frame.width, height: backgroundView.frame.height)

        backgroundView.addSubview(imageView)

        imageView.snp.makeConstraints { make in
            make.center.equalTo(backgroundView)
            make.size.equalTo(backgroundView)
        }
    }

    private func setupMacawView() {
        macawView.backgroundColor = .clear
        backgroundView.addSubview(macawView)

        macawView.snp.makeConstraints { make in
            make.center.equalTo(imageView)
            make.size.equalTo(imageView)
        }

        canvas = Shape(
            form: Rect(x: 0, y: 0, w: Double(UIScreen.main.bounds.width), h: Double(UIScreen.main.bounds.height)),
            fill: Color.clear,
            stroke: Stroke(fill: Color.clear, width: 1.0)
        )

        macawView.node = viewModel.makeSceneRoot(canvas: canvas)
    }

    private func setupCanvasEvents() {
        canvas.onTouchPressed { [weak self] event in
            self?.viewModel.canvasTouchBegan(at: event.points.first?.location(in: .scene))
        }

        canvas.onTouchMoved { [weak self] event in
            guard let location = event.points.first?.location(in: .scene) else { return }
            self?.viewModel.canvasTouchMoved(to: location)
        }

        canvas.onTouchReleased { [weak self] _ in
            self?.viewModel.canvasTouchEnded()
        }
    }

    private func setupColorSelector() {
        colorButton.setColoredButtonText()

        colorSelectorPopup = ColorSelectorPopup(frame: .zero)
        colorSelectorPopup.viewModel = colorSelectorViewModel

        selectorBackground = UIView()
        selectorBackground.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view.addSubview(selectorBackground)
        selectorBackground.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        selectorBackground.addSubview(colorSelectorPopup)
        colorSelectorPopup.snp.makeConstraints { make in
            make.width.equalTo(300)
            make.height.equalTo(330)
            make.center.equalToSuperview()
        }

        selectorBackground.isHidden = true
        view.bringSubviewToFront(selectorBackground)
    }

    private func setupInputContainer() {
        view.addSubview(messageInputContainerView)
        messageInputContainerView.translatesAutoresizingMaskIntoConstraints = false

        messageInputContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        messageInputContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        messageInputContainerView.heightAnchor.constraint(equalToConstant: 48).isActive = true

        bottomConstraint = messageInputContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        bottomConstraint?.isActive = true

        messageInputContainerView.addSubview(inputTextView)
        inputTextView.translatesAutoresizingMaskIntoConstraints = false
        inputTextView.leadingAnchor.constraint(equalTo: messageInputContainerView.leadingAnchor).isActive = true
        inputTextView.trailingAnchor.constraint(equalTo: messageInputContainerView.trailingAnchor).isActive = true
        inputTextView.bottomAnchor.constraint(equalTo: messageInputContainerView.bottomAnchor).isActive = true
        inputTextView.topAnchor.constraint(equalTo: messageInputContainerView.topAnchor).isActive = true
        messageInputContainerView.isHidden = true
        inputTextView.delegate = self

        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    // MARK: - Keyboard

    @objc private func handleKeyboardNotification(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }

        let isKeyboardShowing = notification.name == UIResponder.keyboardWillShowNotification
        viewModel.isKeyboardVisible = isKeyboardShowing

        if isKeyboardShowing {
            bottomConstraint?.constant = -keyboardFrame.height
            if viewModel.isTextEditingActive.value {
                messageInputContainerView.isHidden = false
            }
        } else {
            bottomConstraint?.constant = 0
            messageInputContainerView.isHidden = true
            viewModel.isTextEditingActive.value = false
        }

        view.layoutIfNeeded()
    }

    // MARK: - Actions

    @IBAction func freeDrawingTool(_ sender: UIButton) {
        viewModel.selectTool(.freeDrawing)
    }

    @IBAction func textTool(_ sender: UIButton) {
        viewModel.selectTool(.text)
    }

    @IBAction func activeLineTool(_ sender: UIButton) {
        viewModel.selectTool(.line)
    }

    @IBAction func activeRectTool(_ sender: UIButton) {
        viewModel.selectTool(.rect)
    }

    @IBAction func activeCircleTool(_ sender: Any) {
        viewModel.selectTool(.ellipse)
    }

    @IBAction func activeShapeTool(_ sender: Any) {
        viewModel.selectTool(.protractor)
    }

    @IBAction func activeArrowTool(_ sender: Any) {
        viewModel.selectTool(.arrow)
    }

    @IBAction func activeAsteriskTool(_ sender: Any) {
        viewModel.selectTool(.asterisk)
    }

    @IBAction func activateArcTool(_ sender: UIButton) {
        viewModel.selectTool(.arc)
    }

    @IBAction func activateMultilineTool(_ sender: UIButton) {
        viewModel.selectTool(.multiline)
    }

    @IBAction func activateSelectionTool(_ sender: Any) {
        viewModel.toggleSelectionMode()
    }

    @IBAction func deleteTool(_ sender: UIButton) {
        viewModel.deleteActiveShape()
    }

    @IBAction func colorTool(_ sender: UIButton) {
        colorSelectorViewModel.annotationId = viewModel.activeAnnotationId
        selectorBackground.isHidden = false
    }
}

// MARK: - UIScrollViewDelegate

extension ViewController: UIScrollViewDelegate {

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return backgroundView
    }
}

// MARK: - UITextViewDelegate

extension ViewController: UITextViewDelegate {

    func textViewDidBeginEditing(_ textView: UITextView) {
        guard textView == inputTextView else { return }
        textView.text = viewModel.editingText
    }

    func textViewDidChange(_ textView: UITextView) {
        guard textView == inputTextView else { return }
        if let adjustedText = viewModel.updateEditingText(textView.text ?? "") {
            textView.text = adjustedText
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        guard textView == inputTextView else { return }
        viewModel.endTextEditing(with: textView.text ?? "")
    }
}
