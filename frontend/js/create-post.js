const apiServerUrl = 'http://eco-webapp-alb-291499938.eu-central-1.elb.amazonaws.com';

document.addEventListener('DOMContentLoaded', () => {
    document.getElementById('post-form').addEventListener('submit', e => {
        e.preventDefault();
        
        const postData = {
            title: document.getElementById('title').value,
            author: document.getElementById('author').value,
            category: document.getElementById('category').value,
            image_url: document.getElementById('image_url').value,
            content: document.getElementById('content').value
        };
        
        axios.post(`${apiServerUrl}/post`, postData)
            .then(response => {
                document.getElementById('post-status').innerHTML = 
                    '<div class="alert alert-success">Post created successfully! Redirecting...</div>';
                setTimeout(() => {
                    window.location.href = `post.html?post_id=${response.data.id}`;
                }, 1500);
            })
            .catch(error => {
                document.getElementById('post-status').innerHTML = 
                    `<div class="alert alert-danger">Error: ${error.response?.data?.error || 'Failed to create post'}</div>`;
            });
    });
});
