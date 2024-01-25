//
//  PDFViewController.swift
//  Jaguar2
//
//  Created by Paolo Piccini on 25/03/23.
//

import Foundation
import PDFKit
import RxSwift

class PDFViewController: UIViewController {
  let bag = DisposeBag()
  let documentSubject = PublishSubject<PDFDocument?>()

  private lazy var pdfView: PDFView = {
    let view = PDFView()
    view.translatesAutoresizingMaskIntoConstraints = false
    pdfView.autoScales = true
    return view
  }()

  private lazy var closeButton: UIButton = {
    let view = UIButton(type: .system)
    view.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
    return view
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
    setupConstraints()
    setupBindings()
  }

  private func setupUI() {
    view.addSubview(pdfView)
    view.addSubview(closeButton)
  }

  private func setupConstraints() {
    NSLayoutConstraint.activate([
      pdfView.topAnchor.constraint(equalTo: view.topAnchor),
      pdfView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      pdfView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      pdfView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

      closeButton.topAnchor.constraint(equalTo: pdfView.topAnchor, constant: 20),
      pdfView.trailingAnchor.constraint(equalTo: closeButton.trailingAnchor, constant: 20)
    ])
  }

  private func setupBindings() {
    closeButton.rx.tap
      .subscribe(onNext: { [unowned self] _ in
        self.dismiss(animated: true)
      })
      .disposed(by: bag)

    documentSubject
      .asDriver(onErrorJustReturn: nil)
      .drive(onNext: { [unowned self] pdfDocument in
        pdfView.document = pdfDocument
      }).disposed(by: bag)
  }
}
