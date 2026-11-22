<div class="grid-selector">
    @foreach($self->all(true) as $column => $selector)
        @php
            $columnSelected = \Illuminate\Support\Arr::get($selected, $column, []);
            $hasSelection = ! empty($columnSelected);
        @endphp
        <div class="wrap">
            <div class="select-label">
                {{ $selector['label'] }}
                @if($hasSelection)
                    <a href="{{ $self->url($column) }}" class="clear" title="{{ trans('admin.reset') }}">
                        <i class="feather icon-trash-2"></i>
                    </a>
                @endif
            </div>
            <div class="select-options">
                <ul>
                    @foreach($selector['options'] as $value => $option)
                        @php
                            $active = in_array((string) $value, $columnSelected, true);
                        @endphp
                        <li>
                            <a href="{{ $self->url($column, $value, true) }}"
                               class="{{ $active ? 'active' : '' }}">{{ $option }}</a>
                            @if(! $active && $selector['type'] == 'many' && $hasSelection)
                                &nbsp;
                                <a href="{{ $self->url($column, $value) }}" class="add" title="{{ trans('admin.choose') }}">
                                    <i class="feather icon-plus-square"></i>
                                </a>
                            @else
                                <a class="add-placeholder" style="visibility: hidden;"><i class="feather icon-plus-square"></i></a>
                            @endif
                        </li>
                    @endforeach
                </ul>
            </div>
        </div>
    @endforeach
</div>
