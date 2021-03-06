//
//  PXOneTapHeaderView.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 11/10/18.
//

import UIKit

class PXOneTapHeaderView: PXComponentView {
    private var model: PXOneTapHeaderViewModel {
        willSet(newModel) {
            updateLayout(newModel: newModel, oldModel: model)
        }
    }

    private weak var delegate: PXOneTapHeaderProtocol?
    private var merchantView: PXOneTapHeaderMerchantView?
    private var isShowingHorizontally: Bool = false
    private var verticalLayoutConstraints: [NSLayoutConstraint] = []
    private var horizontalLayoutConstraints: [NSLayoutConstraint] = []
    private var summaryView: PXOneTapSummaryView?

    init(viewModel: PXOneTapHeaderViewModel, delegate: PXOneTapHeaderProtocol?) {
        self.model = viewModel
        self.delegate = delegate
        super.init()
        self.render()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateModel(_ model: PXOneTapHeaderViewModel) {
        self.model = model
    }
}

// MARK: Privates.
extension PXOneTapHeaderView {

    private func shouldShowHorizontally(data: [OneTapHeaderSummaryData]) -> Bool {
        return UIDevice.isSmallDevice() && data.count != 1 && !data[0].isTotal
    }

    private func removeAnimations() {
        self.layer.removeAllAnimations()
        for view in self.getSubviews() {
            view.layer.removeAllAnimations()
        }
    }

    private func updateLayout(newModel: PXOneTapHeaderViewModel, oldModel: PXOneTapHeaderViewModel) {
        removeAnimations()

        let animationDuration = 0.35
        let shouldShowHorizontally = self.shouldShowHorizontally(data: newModel.data)
        let shouldAnimateSummary = newModel.data.count != oldModel.data.count
        let shouldHideSummary = newModel.data.count < oldModel.data.count

        self.layoutIfNeeded()

        if shouldShowHorizontally, !isShowingHorizontally {
            //animate to horizontal
            self.animateToHorizontal(duration: animationDuration)
        } else if !shouldShowHorizontally, isShowingHorizontally {
            //animate to vertical
            self.animateToVertical(duration: animationDuration)
        }

        self.layoutIfNeeded()

        if shouldAnimateSummary {
            let animationDistance: CGFloat = 30
            var animationRows: [UIView] = []
            var pinTopConstraints: [NSLayoutConstraint] = []

            if !shouldHideSummary {
                summaryView?.update(newModel.data, hideAnimatedView: !shouldHideSummary)
            }

            self.layoutIfNeeded()

            if let subviews = summaryView?.getSubviews() {
                for view in subviews {
                    if view.pxShouldAnimatedOneTapRow, let summaryRowView = view as? PXOneTapSummaryRowView, let newRow = summaryView?.getSummaryRowView(with: summaryRowView.data) {

                        newRow.alpha = shouldHideSummary ? 1 : 0
                        animationRows.append(newRow)
                        self.addSubview(newRow)

                        PXLayout.setHeight(owner: newRow, height: summaryRowView.frame.height).isActive = true
                        PXLayout.setWidth(owner: newRow, width: summaryRowView.frame.width).isActive = true

                        let summaryRowViewFrame = summaryRowView.convert(summaryRowView.bounds, to: self)
                        let pinTopConstraint = PXLayout.pinTop(view: newRow, withMargin: summaryRowViewFrame.minY)
                        pinTopConstraint.constant = shouldHideSummary ? pinTopConstraint.constant : pinTopConstraint.constant + animationDistance
                        pinTopConstraint.isActive = true
                        pinTopConstraints.append(pinTopConstraint)
                    }
                }
            }

            summaryView?.update(newModel.data, hideAnimatedView: !shouldHideSummary)

            self.layoutIfNeeded()
            var pxAnimator = PXAnimator(duration: animationDuration, dampingRatio: 1)
            pxAnimator.addAnimation(animation: { [weak self] in
                for (index, view) in animationRows.enumerated() {
                    let pinTopConstraint = pinTopConstraints[index]
                    pinTopConstraint.constant = shouldHideSummary ? pinTopConstraint.constant + animationDistance : pinTopConstraint.constant - animationDistance
                    self?.layoutIfNeeded()
                    view.alpha = shouldHideSummary ? 0 : 1
                }
            })

            pxAnimator.addCompletion { [weak self] in
                if !shouldHideSummary {
                    self?.summaryView?.showAnimatedViews()
                }
                for view in animationRows {
                    view.removeFromSuperview()
                }
            }

            pxAnimator.animate()
        } else {
            summaryView?.update(newModel.data)
        }
    }

    private func animateToVertical(duration: Double = 0) {
        self.isShowingHorizontally = false
        self.merchantView?.animateToVertical(duration: duration)
        var pxAnimator = PXAnimator(duration: duration, dampingRatio: 1)
        pxAnimator.addAnimation(animation: { [weak self] in
            guard let strongSelf = self else {
                return
            }

            for constraint in strongSelf.horizontalLayoutConstraints.reversed() {
                constraint.isActive = false
            }

            for constraint in strongSelf.verticalLayoutConstraints.reversed() {
                constraint.isActive = true
            }
            strongSelf.layoutIfNeeded()
        })

        pxAnimator.animate()
    }

    private func animateToHorizontal(duration: Double = 0) {
        self.isShowingHorizontally = true
        self.merchantView?.animateToHorizontal(duration: duration)
        var pxAnimator = PXAnimator(duration: duration, dampingRatio: 1)
        pxAnimator.addAnimation(animation: { [weak self] in
            guard let strongSelf = self else {
                return
            }

            for constraint in strongSelf.horizontalLayoutConstraints.reversed() {
                constraint.isActive = true
            }

            for constraint in strongSelf.verticalLayoutConstraints.reversed() {
                constraint.isActive = false
            }
            strongSelf.layoutIfNeeded()
        })

        pxAnimator.animate()
    }

    private func render() {
        removeAllSubviews()
        self.pinContentViewToBottom()
        backgroundColor = ThemeManager.shared.navigationBar().backgroundColor

        let summaryView = PXOneTapSummaryView(data: model.data)
        self.summaryView = summaryView

        addSubview(summaryView)
        PXLayout.matchWidth(ofView: summaryView).isActive = true
        PXLayout.pinBottom(view: summaryView).isActive = true

        let showHorizontally = shouldShowHorizontally(data: model.data)
        let merchantView = PXOneTapHeaderMerchantView(image: model.icon, title: model.title, showHorizontally: showHorizontally)
        self.merchantView = merchantView
        self.addSubview(merchantView)

        let horizontalConstraints = [PXLayout.pinTop(view: merchantView, withMargin: -PXLayout.XXL_MARGIN),
                                     PXLayout.put(view: merchantView, aboveOf: summaryView, withMargin: -PXLayout.M_MARGIN),
                                     PXLayout.centerHorizontally(view: merchantView),
                                     PXLayout.matchWidth(ofView: merchantView)]

        self.horizontalLayoutConstraints.append(contentsOf: horizontalConstraints)

        let verticalLayoutConstraints = [PXLayout.pinTop(view: merchantView),
                                         PXLayout.put(view: merchantView, aboveOf: summaryView, relation: .greaterThanOrEqual),
                                         PXLayout.centerHorizontally(view: merchantView),
                                         PXLayout.matchWidth(ofView: merchantView)]

        self.verticalLayoutConstraints.append(contentsOf: verticalLayoutConstraints)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleSummaryTap))
        summaryView.addGestureRecognizer(tapGesture)

        if showHorizontally {
            animateToHorizontal()
        } else {
            animateToVertical()
        }
    }
}

// MARK: Publics.
extension PXOneTapHeaderView {
    @objc func handleSummaryTap() {
        delegate?.didTapSummary()
    }
}
