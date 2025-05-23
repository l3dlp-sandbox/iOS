import MEGADesignToken
import MEGASwiftUI
import MEGAUIKit
import SwiftUI

public struct SearchResultsView: View {
    @StateObject var viewModel: SearchResultsViewModel
    @Environment(\.editMode) private var editMode
    
    public init(viewModel: @autoclosure @escaping () -> SearchResultsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }
    
    public var body: some View {
        VStack(spacing: .zero) {
            chips
            PlaceholderContainerView(
                isLoading: $viewModel.isLoadingPlaceholderShown,
                content: content,
                placeholder: PlaceholderContentView(
                    placeholderRow: placeholderRowView
                )
            )
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: .top
            )
        }
        .task {
            await viewModel.task()
        }
        .sheet(item: $viewModel.presentedChipsPickerViewModel) { item in
            if #available(iOS 16, *) {
                chipsPickerView(for: item)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            } else {
                chipsPickerView(for: item)
            }
        }
    }
    
    @ViewBuilder
    private var chips: some View {
        HStack {
            ForEach(viewModel.chipsItems) { chip in
                PillView(viewModel: chip.pill)
                    .onTapGesture {
                        Task { @MainActor in
                            await chip.select()
                        }
                    }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding([.leading, .trailing, .bottom])
        .padding(.top, 6)
    }
    
    private func chipsPickerView(for item: ChipViewModel) -> some View {
        ChipsPickerView(
            viewModel: .init(
                title: item.subchipsPickerTitle ?? "",
                chips: item.subchips,
                closeIcon: viewModel.chipAssets.closeIcon,
                colorAssets: viewModel.colorAssets,
                chipSelection: { chip in
                    Task { @MainActor in
                        await chip.select()
                    }
                },
                dismiss: {
                    Task { @MainActor in
                        await viewModel.dismissChipGroupPicker()
                    }
                }
            )
        )
    }
    
    @ViewBuilder
    private var content: some View {
        Group {
            if #available(iOS 16.0, *) {
                contentWrapper
                    .scrollDismissesKeyboard(.immediately)
            } else {
                if viewModel.layout == .list && viewModel.containsSwipeActions {
                    // Drag gesture conflicts with the swipe left for listing.
                    // Hence it is not enabled for iOS 15 and below devices if there is swipe.
                    contentWrapper
                } else {
                    contentWrapper
                        .simultaneousGesture(
                            DragGesture().onChanged({ _ in
                                viewModel.scrolled()
                            })
                        )
                }
            }
        }
        .padding(.bottom, viewModel.bottomInset)
        .emptyState(viewModel.emptyViewModel)
    }
    
    @ViewBuilder
    private var contentWrapper: some View {
        if viewModel.layout == .list {
            listContent
        } else {
            thumbnailContent
        }
    }

    private var listContent: some View {
        SearchResultsListView(viewModel: viewModel)
    }

    private var thumbnailContent: some View {
        GeometryReader { geo in
            ScrollView {
                LazyVGrid(
                    columns: viewModel.columns(geo.size.width)
                ) {
                    ForEach(viewModel.folderListItems) { item in
                        SearchResultThumbnailItemView(
                            viewModel: item,
                            selected: $viewModel.selectedResultIds,
                            selectionEnabled: $viewModel.editing
                        )
                        .onAppear {
                            Task {
                                await viewModel.onItemAppear(item)
                            }
                        }
                    }
                }
                .padding(.horizontal, 8)
                
                LazyVGrid(
                    columns: viewModel.columns(geo.size.width)
                ) {
                    ForEach(viewModel.fileListItems) { item in
                        SearchResultThumbnailItemView(
                            viewModel: item,
                            selected: $viewModel.selectedResultIds,
                            selectionEnabled: $viewModel.editing
                        )
                        .onAppear {
                            Task {
                                await viewModel.onItemAppear(item)
                            }
                        }
                    }
                }
                .padding(.horizontal, 8)
            }
        }
    }
    
    private var placeholderRowView: some View {
        HStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 0)
                .frame(width: 40, height: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                RoundedRectangle(cornerRadius: 100)
                    .frame(width: 152, height: 20)
                
                RoundedRectangle(cornerRadius: 100)
                    .frame(width: 121, height: 20)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            RoundedRectangle(cornerRadius: 0)
                .frame(width: 28, height: 28)
        }
        .padding()
        .shimmering()
    }
}

#Preview {
    struct Wrapper: View {
        @State var text: String = ""
        @StateObject var viewModel = SearchResultsViewModel(
            resultsProvider: NonProductionTestResultsProvider(empty: true),
            bridge: .init(
                selection: { _ in },
                context: {_, _ in },
                resignKeyboard: {},
                chipTapped: { _, _ in },
                sortingOrder: { .nameAscending }
            ),
            config: .example,
            layout: .list,
            keyboardVisibilityHandler: MockKeyboardVisibilityHandler(),
            viewDisplayMode: .unknown,
            isSearchByNodeTagsFeatureEnabled: true,
            listHeaderViewModel: nil,
            isSelectionEnabled: false
        )
        var body: some View {
            SearchResultsView(viewModel: viewModel)
            .onChange(of: text, perform: { newValue in
                viewModel.bridge.queryChanged(newValue)
            })
            .searchable(text: $text)
        }
    }
    
    return NavigationView {
        Wrapper()
    }
}
