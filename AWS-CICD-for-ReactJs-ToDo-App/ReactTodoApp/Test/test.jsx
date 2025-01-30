import React from 'react';
import { render, fireEvent, waitFor } from '@testing-library/react';
import App from '../src/App';

describe('Todo App', () => {
  it('should add a new task to the list', async () => {
    const { getByLabelText, getByText, getAllByText } = render(<App />);
    const input = getByLabelText(/Enter a new task/i);
    const addButton = getByText(/Add Task/i);

    fireEvent.change(input, { target: { value: 'Buy milk' } });
    fireEvent.click(addButton);

    await waitFor(() => getAllByText(/mytest/i).length === 1);
  });
});
