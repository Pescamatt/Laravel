<x-layout>
    <x-slot:heading>Jobs Page</x-slot:heading>

    <ul>
        @foreach( $jobs as $job)
            <li>
                <a href="/jobs/{{$job['id']}}" class="text-red-500 hover:underline"><strong>{{ $job['title'] }}</strong>: Pays {{ $job['salary'] }} pro years</a>
            </li>
        @endforeach
    </ul>
</x-layout>
