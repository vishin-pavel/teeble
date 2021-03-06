# =require '/../table-renderer'
# =require './row_view'
# =require './header_view'
# =require './footer_view'
# =require './pagination_view'
# =require './empty_view'

class @Teeble.TableView extends Backbone.View

    tagName : 'div'

    classes:
        sorting:
            sortable_class: 'sorting'
            sorted_desc_class: 'sorting_desc'
            sorted_asc_class: 'sorting_asc'
        pagination:
            pagination_class: 'pagination'
            pagination_active: 'active'
            pagination_disabled: 'disabled'

    subviews:
        header: Teeble.HeaderView
        row: Teeble.RowView
        footer: Teeble.FooterView
        pagination: Teeble.PaginationView
        renderer: Teeble.TableRenderer
        empty: Teeble.EmptyView


    initialize : =>
        @subviews = _.extend {}, @subviews, @options.subviews

        @events = _.extend {}, @events,
            'click a.first': 'gotoFirst'
            'click a.previous': 'gotoPrev'
            'click a.next': 'gotoNext'
            'click a.last': 'gotoLast'
            'click a.pagination-page': 'gotoPage'

            'click .sorting': 'sort'

        @setOptions()

        super

        @collection.on('add', @addOne, @)
        @collection.on('reset', @renderBody, @)
        @collection.on('reset', @renderPagination, @)

        @renderer = new @subviews.renderer
            partials: @options.partials
            table_class: @options.table_class
            cid: @cid
            classes: @classes

    setOptions: =>
        @


    render: =>
        @$el.empty().append("<table><tbody></tbody></table")
        @table = @$('table').addClass(@options.table_class)
        @body = @$('tbody')

        @renderHeader()
        @renderBody()
        @renderFooter()
        @renderPagination()
        @

    renderPagination : =>
        if @options.pagination
            @pagination?.remove()
            @pagination = new @subviews.pagination
                renderer: @renderer
                collection: @collection
                pagination: @classes.pagination

            @$el.append(@pagination.render().el)

    renderHeader : =>
        @header?.remove()
        @header = new @subviews.header
            renderer: @renderer
            collection: @collection

        @table.prepend(@header.render().el)

    renderFooter : =>
        if @options.footer
            @footer?.remove()

            if @collection.length > 0
                @footer = new @subviews.footer
                    renderer: @renderer
                    collection: @collection

                @table.append(@footer.render().el)

    renderBody : =>
        @body.empty()

        if @collection.length > 0
            @collection.each(@addOne)
        else
            @renderEmpty()

    renderEmpty : =>
        @empty = new @subviews.empty
            renderer: @renderer
            collection: @collection

        @body.append(@empty.render().el)


    addOne : ( item ) =>
        view = new @subviews.row
            model: item
            renderer: @renderer

        @body.append(view.render().el)

    gotoFirst: (e) =>
        e.preventDefault()
        @collection.goTo(1)

    gotoPrev: (e) =>
        e.preventDefault()
        @collection.previousPage()

    gotoNext: (e) =>
        e.preventDefault()
        @collection.nextPage()

    gotoLast: (e) =>
        e.preventDefault()
        @collection.goTo(this.collection.information.lastPage)

    gotoPage: (e) =>
        e.preventDefault()
        page = @$(e.target).text()
        @collection.goTo(page)

    _sort: (e, direction) =>
        e.preventDefault()

        @$el.find(".#{@classes.sorting.sortable_class}").removeClass("#{@classes.sorting.sorted_desc_class} #{@classes.sorting.sorted_asc_class}")
        $this = @$(e.target)
        if not $this.hasClass(@classes.sorting.sortable_class)
            $this = $this.parents(".#{@classes.sorting.sortable_class}")

        classDirection = "sorted_#{direction}_class"
        $this.addClass("#{@classes.sorting[classDirection]}")
        currentSort = $this.attr('data-sort')
        @collection.setSort(currentSort, direction)
        @renderBody()
        @renderPagination()

    sort: (e) =>
        $this = @$(e.currentTarget)
        if $this.hasClass(@classes.sorting.sorted_desc_class)
            @_sort(e, 'asc')
        else
            @_sort(e, 'desc')

